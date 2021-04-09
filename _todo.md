Phase II work for LCS content:

* Update the content to the latest version of CPG (applied)
* Publish the content on fhir.org/guides (in-progress)
* Publish the content in CDS Connect (waiting on publication on fhir.org)

It’s likely the following will change in the near future:
- URL reference to the USPSTF guideline (it’s being updated now -- https://www.uspreventiveservicestaskforce.org/uspstf/draft-update-summary/lung-cancer-screening1)
- 30 pack year requirement à 20 pack year requirement
- 55-80 age requirement à 50-80 age requirement


# Steps to apply this update:

## 1. Update the version of the implementation guide

Update the `version` element of the [lcs-cds Implementation Guide resource](input/lcs-cds.xml)

This change will be automatically applied to all the resources published as part of the IG.

## 2. Update any references

If the URL of the recommendation changes, change it where it appears:

1. [LCS Recommendation Page](input/pagecontent/lcs-recommendation.xml)
2. [Library Related Artifact Citation](input/resources/library/library-LungCancerScreening.json)
3. [PlanDefinition Related Artifact Citation](input/resources/plandefinition/plandefinition-lcs-cds-patient-view.json)

## 3. Update the logic

Update the [CQL logic](input/cql/LungCancerScreening.cql):

1. Expression `"55 through 80"` to determine the age, needs to be renamed to reflect age change as well as the logic
2. Expression `"Has 30 pack-year smoking history"`, needs to be renamed to reflect the change in years, as well as the logic
3. Expression `"Inclusion Criteria"` will need to be updated to reference the updated criteria expressions.

## 4. Refresh the artifacts

Run the `_refresh.bat` or `_refresh.sh` script as appropriate for your environment (Windows vs Linux) to refresh the generated content in the Library resource.

## 5. Rebuild the IG

Run the `_genonce.bat` or `_genonce.sh` script to rebuild the implementation guide. This should result in a clean build with no errors.

## 6. Commit the change to the repository

Commit the change to the [lcs-cds repository](http://github.com/cqframework/lcs-cds), this will kick off the auto-build and update the [CI Build](http://build.fhir.org/ig/cqframework/lcs-cds).

## 7. Release

Submit the updated content for release to the FHIR foundation, and CDS Connect repositories.
