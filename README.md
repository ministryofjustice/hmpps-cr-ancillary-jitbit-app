# HMPPS CR Ancillary Jitbit App

[![repo standards badge](https://img.shields.io/badge/dynamic/json?color=blue&style=for-the-badge&logo=github&label=MoJ%20Compliant&query=%24.result&url=https%3A%2F%2Foperations-engineering-reports.cloud-platform.service.justice.gov.uk%2Fapi%2Fv1%2Fcompliant_public_repositories%2Fhmpps-cr-ancillary-jitbit-app)](https://operations-engineering-reports.cloud-platform.service.justice.gov.uk/public-github-repositories.html#hmpps-cr-ancillary-jitbit-app "Link to report")

### Github Actions

There is a workflow for pushing the Jitbit app image to the Modernisation Platform core-shared-services ECR, `image-build-push.yml`.

By default this will perform a docker build of app, but will NOT push to the ECR.

To push an image to the ecr, include the phrase `ecr_push` in the commit message.
