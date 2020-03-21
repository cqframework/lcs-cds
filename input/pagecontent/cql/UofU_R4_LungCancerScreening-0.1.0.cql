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
valueset "Condition Clinical Status": 'http://utah.edu/fhir/lcs-cds/ValueSet/conditionclinical'

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

/* QUESTION: Do we want to consider a limit for how far back to look for smoking status observations?
*/

define "Current smoker observation":
  Last([Observation: "Tobacco Smoking Status"] O
    where O.status in { 'final', 'amended' }
    and (
          FHIRHelpers.ToConcept(O.value as CodeableConcept) in "Current Smoker"
          or FHIRHelpers.ToConcept(O.value as CodeableConcept) ~ "Former Smoker"
        )
       sort by (FHIRHelpers.ToDateTime(issued))
    )

define "Is current smoker":
    ("Current smoker observation" O
      where FHIRHelpers.ToConcept(O.value as CodeableConcept) in "Current Smoker"
    ) is not null

define "Is former smoker who quit within past 15 years":
  ("Current smoker observation" O
    where FHIRHelpers.ToConcept(O.value as CodeableConcept) ~ "Former Smoker"
    and O.effective ends 15 years or less before Today()
  ) is not null

define "Pack-years":
  "Current smoker observation" O
    let PacksPerDay: FHIRHelpers.ToQuantity(singleton from (O.component C where FHIRHelpers.ToConcept(C.code) ~ "PACKS A DAY").value),
    DurationInDays: duration in days between O.effective.start and O.effective.end
    return PacksPerDay * (DurationInDays / 365)

define "Has 30 pack-year smoking history":
  "Pack-years" >= 30

define "Has lung cancer":
  exists (
    [Condition: "Lung Cancer"] C
      where FHIRHelpers.ToConcept(C.clinicalStatus as CodeableConcept) in "Condition Clinical Status"
  )

define "Had chest CT in past year":
  exists(
    [Procedure: "Chest CT"] P
      where P.status = 'completed'
      and Global."Normalize Interval"(P.performed) ends 1 year or less before Today()
  )
