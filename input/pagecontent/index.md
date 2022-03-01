### Introduction

This implementation guide provides resources and discussion for applying the USPSTF's recommendations on Lung Cancer Screening.

Note that the content of this implementation guide is draft material that has not yet been tested or validated for use in production environments.

### Scope

From a functional perspective, this implementation guide provides documentation in support of applying the USPSTF's Final Recommendation Statement on Lung Cancer Screening as part of determining whether shared decision making is appropriate for patients.

From a technical perspective, this implementation guide provides a computable representation of the logic involved in the recommendation statement that can be used to streamline implementation of the recommendation in a clinical system. The artifacts provided in this implementation guide can be deployed in a variety of ways, as discussed in the [Mechanisms of Integration](http://hl7.org/fhir/uv/cpg/documentation-approach-10-mechanisms-of-integration.html) and [Methods of Implementation](http://hl7.org/fhir/uv/cpg/documentation-approach-09-methods-of-implementation.html) sections of the FHIR Clinical Guidelines implementation guide.

### Roadmap
This project was initially developed as part of an Agency for Health Research and Quality R18 grant.[^1] Ongoing maintenance will use the [FHIR Community Process](http://fhir.org/community/process/). For complete documentation on the change management process used, refer to the [Change Management](https://github.com/cqframework/lcs-cds/blob/master/CHANGE_MANAGEMENT.md) documentation.

This first release of the LCS CDS implementation guide supports use of CQL v1.4+ with FHIR v4.01 and CPG v1.0.0. This content will be periodically updated as required to incorporate support for new versions of FHIR, CQL, and CPG as they are published, and as needed by projects that make use of these assets.

To submit feedback on this project, submit a [New Issue](https://github.com/cqframework/lcs-cds/issues/new) on Github (also linked in the Propose a change link in the footer of every page of the IG).

### Contents

This implementation guide includes support for the following guideline recommendation:

[Final Recommendation Statement -- Lung Cancer Screening](lcs-recommendation.html "Final Recommendation Statement -- Lung Cancer Screening")

[^1]: This work was funded by a grant from the Agency for Healthcare Research and Quality (AHRQ): AHRQ grant R18 HS026198.
