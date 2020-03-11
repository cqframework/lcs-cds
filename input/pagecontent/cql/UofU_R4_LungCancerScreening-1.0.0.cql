library UofU_R4_LungCancerScreening version '1.0.0'

using FHIR version '4.0.0'

include FHIRHelpers version '4.0.0' called FHIRHelpers
include MATGlobalCommonFunctions_FHIR4 version '4.0.000' called Global

codesystem "SNOMED": 'http://snomed.info/sct'
codesystem "UTAH_EDU": 'http://utah.edu/epic'
codesystem "LOINC": 'http://loinc.org'

valueset "Lung Cancer":  'http://cts.nlm.nih.gov/fhir/ValueSet/2.16.840.1.113762.1.4.1116.89'
valueset "Smoking Status": 'http://hl7.org/fhir/us/core/ValueSet/us-core-observation-smokingstatus'
valueset "Current Smoker": 'TODO'
valueset "Chest CT": 'http://utah.edu/epic/proc_code'

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

define "Is current smoker":
  exists (
    [Observation] O
      where FHIRHelpers.ToCode(singleton from O.code.coding) ~ "Tobacco Smoking Status"
      and FHIRHelpers.ToConcept(O.value as CodeableConcept) in "Current Smoker"
  )

define "Is former smoker who quit within past 15 years":
  exists (
    [Observation] O
      where FHIRHelpers.ToCode(singleton from O.code.coding) ~ "Tobacco Smoking Status"
      and singleton from FHIRHelpers.ToConcept(O.value as CodeableConcept).codes ~ "Former Smoker"
      and duration in years between O.effective.end and Now() < 15
  )

define "Packs per day":
  [Observation] O
    return FHIRHelpers.ToQuantity(singleton from (O.component C where FHIRHelpers.ToConcept(C.code) ~ "PACKS A DAY").value).value

define "Duration years":
  [Observation] O
    return duration in years between O.effective.start and O.effective.end

define "Duration days":
  [Observation] O
    return duration in days between O.effective.start and O.effective.end

define "Has 30 pack-year smoking history":
exists (
  if "Is current smoker" or "Is former smoker who quit within past 15 years"
    then [Observation] O
      where First("Duration days") * First("Packs per day") / First("Duration years") >= 30
  else null
)

define "Has lung cancer":
  exists (
    [Condition] C
      where singleton from FHIRHelpers.ToConcept(C.clinicalStatus as CodeableConcept).codes in { ToConcept(Global."active"), ToConcept(Global."recurrence"), ToConcept(Global."relapse") }
      and singleton from FHIRHelpers.ToConcept(C.code as CodeableConcept).codes in "Lung Cancer"
  )

define "Had chest CT in past year":
  exists(
  [Procedure] P
    where P.status = 'completed'
    and singleton from FHIRHelpers.ToConcept(P.code as CodeableConcept).codes in "Chest CT"
    and duration in years between P.performed and Now() < 1
  )
