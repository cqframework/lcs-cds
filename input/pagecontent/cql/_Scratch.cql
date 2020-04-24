library _Scratch version '0.1.0'

using FHIR version '4.0.0'

include FHIRHelpers version '4.0.0' called FHIRHelpers

codesystem "LOINC": 'http://loinc.org'

code "Tobacco Smoking Status": '72166-2' from "LOINC"

context Patient

define "Test Retrieve": [Observation: "Tobacco Smoking Status"]
define "Test Where": [Observation] O where O.code ~ "Tobacco Smoking Status"
