library UofU_R4_LungCancerScreening version '0.1.0'

using FHIR version '4.0.0'

include FHIRHelpers version '4.0.0' called FHIRHelpers
include MATGlobalCommonFunctions_FHIR4 version '4.0.000' called Global

codesystem "SNOMED": 'http://snomed.info/sct'
codesystem "UTAH_EDU": 'http://utah.edu/fhir/lcs-cds/CodeSystem/proc_code'
codesystem "LOINC": 'http://loinc.org'

valueset "Lung Cancer":  'http://cts.nlm.nih.gov/fhir/ValueSet/2.16.840.1.113762.1.4.1116.89'
valueset "Smoking Status": 'http://hl7.org/fhir/us/core/ValueSet/us-core-observation-smokingstatus'
valueset "Current Smoker": 'http://utah.edu/fhir/lcs-cds/ValueSet/currentsmoker'
valueset "Chest CT": 'http://utah.edu/fhir/lcs-cds/ValueSet/chest_ct_proc_code'

code "Tobacco Smoking Status": '72166-2' from "LOINC"
code "Former Smoker": '8517006' from "SNOMED"
code "PACKS A DAY": '8663-7' from "LOINC" display 'packs per day'

context Patient

define "Inclusion Criteria":
  "55 through 80"
  and ("Is current smoker" or "Is former smoker who quit within past 15 years")
  and "Has 30 pack-year smoking history"
  and not "Has lung cancer"
  and not "Had chest CT in past year"

  define "Is Eligible Detail":
    if "Inclusion Criteria"
      then 'Potential eligible patient: ' + First(Patient.name).text +
        ': Born ' + ToString(Patient.birthDate) +
        ' (Age: ' + ToString(AgeInYears()) +
        '), Gender: ' + Patient.gender
    else null

define "Is Eligible Summary":
  if "Inclusion Criteria"
    then 'Recommend shared decision making for lung cancer screening'
  else null

define "Is Eligible Indicator":
  if "Inclusion Criteria"
    then 'info'
  else null

define "Exclusion Criteria":
  (
    not ("Is current smoker" or "Is former smoker who quit within past 15 years")
    or "Has lung cancer"
  )

define "Exclusion Detail":
  if "Exclusion Criteria"
    then First(Patient.name).text +
      ': Born ' + ToString(Patient.birthDate) +
      ' (Age: ' + ToString(AgeInYears()) +
      '), Gender: ' + Patient.gender
    else null

define "Exclusion Summary":
  if "Exclusion Criteria"
    then 'Patient is not currently recommended for lung cancer screening'
  else null

define "Exclusion Indicator":
  if "Exclusion Criteria"
    then 'info'
  else null

define "55 through 80":
  AgeInYears() >= 55 and AgeInYears() <= 80

/* REVIEW:
1. Pulling a coding out from a codeableconcept like this is an anti-pattern, codeable concepts should be almost always be treated at the concept level
2. Why not put the reference to "Tobacco Smoking Status" in the retrieve? Observation.code is the primary code path for the resource?
3. What happens if there are multiple observations that meet this? We need to consider only the most recent tobacco smoking status observation,
and make sure that one is Current Smoker, using the issued element to determine the most recent
4. For consistency and reuse, consider defining a "Current smoker observation" and using that from within this
*/
/* QUESTION: Do we want to consider a limit for how far back to look for smoking status observations?
*/
define "Is current smoker":
  exists (
    [Observation] O
      where O.status in { 'final', 'amended' }
      and FHIRHelpers.ToCode(singleton from O.code.coding) ~ "Tobacco Smoking Status"
      and FHIRHelpers.ToConcept(O.value as CodeableConcept) in "Current Smoker"
  )

/* REVIEW:
1. Same issue with singleton from coding
2. Same issue with observation and the retrieve
3. Don't extract a singleton from the codeable concept for comparison, just let the implicit conversion from a code to a concept happen
4. Don't need to test O.effective.end is not null, the null will propagate through the period comparison and result in false
5. Same issue with multiple observations, consider only the most recent observation
6. Consider defining a "Current smoker observation" and reusing in this expression and the other one related to determining pack-year history
7. Characterization of the duration is a bit hard to follow, consider O.effective ends 15 years or less before Today()
*/
define "Is former smoker who quit within past 15 years":
  exists (
    [Observation] O
      where O.status in { 'final', 'amended' }
      and FHIRHelpers.ToCode(singleton from O.code.coding) ~ "Tobacco Smoking Status"
      and singleton from FHIRHelpers.ToConcept(O.value as CodeableConcept).codes ~ "Former Smoker"
      and duration in years between O.effective.end and Now() < 15
  )

/* REVIEW:
1. If you assume multiple observations indicating packs per day, the likelihood of that
presenting a consistent enough history across time to support actual calculation is quite low.
We ought to be using the most recent smoking status observation that indicates a current smoker.
2. Pulling the packs/day value from the component looks good
3. Suggest reusing the "Current smoker observation" definition from above to perform this calculation, all of these would go away then...
*/
define "Packs per day":
  Avg([Observation] O
    where O.status in { 'final', 'amended' }
      return FHIRHelpers.ToQuantity(singleton from (O.component C where FHIRHelpers.ToConcept(C.code) ~ "PACKS A DAY").value).value)

define "Duration years":
  Avg([Observation] O
    where O.status in { 'final', 'amended' }
      return duration in years between O.effective.start and O.effective.end)

define "Duration days":
  Avg([Observation] O
    where O.status in { 'final', 'amended' }
      return duration in days between O.effective.start and O.effective.end)

/* REVIEW:
1. The "Duration years" reference here isn't right, the result of Duration days * Packs per day would be number of packs, need to divide by days / year to get pack years (i.e. divide by 365)
2. However, pack-year calculation is actually packs per day * number of years (note that for this calculation, we actually want the duration in days / 365 to get annum, not calendar years)
3. So:
define "Pack-years":
  "Current smoker" O
    let PacksPerDay: FHIRHelpers.ToQuantity(singleton from (O.component C where FHIRHelpers.ToConcept(C.code) ~ "PACKS A DAY").value)
    let DurationInDays: duration in days between O.effective.start and O.effective.end
  return PacksPerDay * (DurationInDays / 365)
*/
define "Has 30 pack-year smoking history":
  exists (
    [Observation] O
      where O.status in { 'final', 'amended' }
      and "Duration days" * "Packs per day" / "Duration years" >= 30
  )

/* REVIEW:
1. Same issue with singleton from
2. Same issue with retrieve terminology target
3. Don't use lists to construct value sets like this, MUST create a value set for this
*/
define "Has lung cancer":
  exists (
    [Condition] C
      where singleton from FHIRHelpers.ToConcept(C.clinicalStatus as CodeableConcept).codes in { ToConcept(Global."active"), ToConcept(Global."recurrence"), ToConcept(Global."relapse") }
      and singleton from FHIRHelpers.ToConcept(C.code as CodeableConcept).codes in "Lung Cancer"
  )

/* REVIEW:
1. Same issue with singleton from
2. Same issue with retrieve not using terminology target
3. Note that performed can be a period or datetime, logic needs to account for that (use Normalize Interval from GlobalCommon)
4. Characterization is a bit hard to follow, why not just say "performed ends 1 year or less before Today()"?
*/
define "Had chest CT in past year":
  exists(
    [Procedure] P
      where P.status = 'completed'
      and singleton from FHIRHelpers.ToConcept(P.code as CodeableConcept).codes in "Chest CT"
      and duration in years between P.performed and Now() < 1
  )
