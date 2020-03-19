1. Guide canonical base should be: http://utah.edu/fhir/lcs-cds
2. Guide version should be 0.1.0
3. All artifacts in the guide should be this version
4. CQL file names should not carry the version
5. CodeSystem resource:
  * name should be a machine readable name with meaning and uniqueness within the namespace of the URL
    * proc_code
  * id should be a web-version of name:
    * proc_code
  * url should be the canonical for the CodeSystem:
    http://utah.edu/fhir/lcs-cds/CodeSystem/proc_code
  * version should be same as the guide version (or left out, just be sure the publisher is setting it to the guide version)
  * publisher is University of Utah (they are the stewards of the code system)
  * Note in the description of the CodeSystem that this is a partial code system list to support publication of this content
  * valueset reference is invalid, see the ValueSet resource review next
6. ValueSet ChestCT.json resource:
  * name should be a machine readable name with meaning and uniqueness within the namespace of the URL
    * chest_ct_proc_code
  * id should be a web-version of name:
    * chest_ct_proc_code
  * url should be the canonical for the ValueSet:
    http://utah.edu/fhir/lcs-cds/ValueSet/chest_ct_proc_code
  * version should be same as the guide version (or left out, just be sure the publisher is setting it to the guide version)
  * publisher is University of Utah
  * Note in the description that these are local codes, specific to the University of Utah system
7. ValueSet CurrentSmoker.json
  * name should be machine readable name with meaning and uniqueness within the namespace of the URL
    * CurrentSmoker
  * id should be web-version of the name:
    * currentsmoker
  * url should be the canonical for the value set:
    http://utah.edu/fhir/lcs-cds/ValueSet/currentsmoker
  * version, publisher
  * description and copyright are good, definitely keep
8. ValueSet LungCancer.json
  * Looks good, so long as this is exactly the content that was pulled from the VSAC
9. USCoreSmokingStatus.json
  * Looks good, again so long as this is exactly the content that was pulled from US Core and we note on the terminologies page that value set content is duplicated here to support testing
10. Library, PlanDefinition resources look good except they need a URL
11. Functional description should be from a clinician's perspective, right now it's just the CQL, needs to use the language of the recommendation statement (i.e. current smoker, not Observation with code X and value in)
12. Function description: I don't see the reference to 30 pack-year smoking history...
13. See CQL file for more review
14. Where I've noted "QUESTION:" in the CQL, those are questions for UofU, leave those in and we'll get their input on them
