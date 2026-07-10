# Changelog

All notable changes to the Eventdisplay_AnalysisScripts_CTA project will be documented in this file.
Changes for upcoming releases can be found in the [docs/changes](docs/changes) directory.
Note that changes before release v2.5.0 are not documented here.

This changelog is generated using [Towncrier](https://towncrier.readthedocs.io/).

<!-- towncrier release notes start -->

## [v2.5.0](https://github.com/Eventdisplay/Eventdisplay_AnalysisScripts_CTA/releases/tag/v2.5.0) - 2026-07-10

### Bugfixes

- Fix minor-medium bugs report by Copilot code review. ([#69](https://github.com/Eventdisplay/Eventdisplay_AnalysisScripts_CTA/issues/69))

### New Feature

- Add analysis parameters for Prod6-South Paranal analysis (including layout lists).
  ([#63](https://github.com/Eventdisplay/Eventdisplay_AnalysisScripts_CTA/issues/63))
 - Introduce multi-core HTCondor submission.
- Introduce usage of high-multiplicity model for XGBoost. ([#65](https://github.com/Eventdisplay/Eventdisplay_AnalysisScripts_CTA/issues/65))
- Improve efficiency of python scripts: don't run Conda on nodes. ([#66](https://github.com/Eventdisplay/Eventdisplay_AnalysisScripts_CTA/issues/66))
- Improve separation of training and test data for TMVA and XGBoost analysis scripts. ([#67](https://github.com/Eventdisplay/Eventdisplay_AnalysisScripts_CTA/issues/67))

### Maintenance

- Change to ROOT version 6.40.00. ([#63](https://github.com/Eventdisplay/Eventdisplay_AnalysisScripts_CTA/issues/63))
- Initial setup of Changelog generation using towncrier. ([#64](https://github.com/Eventdisplay/Eventdisplay_AnalysisScripts_CTA/issues/64))
- Bugfix related to telescope multiplicity and XGB model selection. ([#70](https://github.com/Eventdisplay/Eventdisplay_AnalysisScripts_CTA/issues/70))
