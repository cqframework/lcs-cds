library _Scratch version '0.1.0'

using FHIR version '4.0.0'

include FHIRHelpers version '4.0.0' called FHIRHelpers

codesystem "LOINC": 'http://loinc.org'

valueset "Current Smoker": 'http://utah.edu/fhir/lcs-cds/ValueSet/currentsmoker'

code "Tobacco Smoking Status": '72166-2' from "LOINC"

context Patient

define "Test Observation": [Observation: "Tobacco Smoking Status"]
define "Test Observation in Value Set": "Test Observation" O where O.value in "Current Smoker"
