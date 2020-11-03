 
[![img](https://img.shields.io/badge/Lifecycle-Dormant-%23ff7f2a)](https://github.com/bcgov/repomountie/blob/master/doc/lifecycle-badges.md)
[![License](https://img.shields.io/badge/License-Apache%202.0-blue.svg)](https://opensource.org/licenses/Apache-2.0)


bc-econ-status-indices
============================

A set of R scripts that use de-personalized Statistics Canada income tax data to generate area-based economic status indices for British Columbia.

The annual income tax data in this repository are from Statistics Canada relased under the [Statistics Canada Open Licence](https://www.statcan.gc.ca/eng/reference/licence). 

### Usage 

The source .csv files are tidied de-pesonalized individual and family income tax data and are placed in the `input-data` subfolder.  

The codes for synthesizing data and making economic indices are in `R` subfolder, named `synthesize_data.R` and `indicies.R` respectively. The `set.up.R` script contains the project's library dependencies. 

The urban and rural indices designated as urban quintile (UQ) and rural quintile (RQ) are saved in .csv files in the `output-data` subfolder.  

Insights developed from analyses of data tables and references are provided in `.Rmd` format in the  `docs` subfolder.


### Getting Help or Reporting an Issue 

To report bugs/issues/feature requests, please file an [issue](https://github.com/bcgov/bc-econ-status-indices/issues/).

### How to Contribute

If you would like to contribute, please see our [CONTRIBUTING](CONTRIBUTING.md) guidelines.

Please note that this project is released with a [Contributor Code of Conduct](CODE_OF_CONDUCT.md). By participating in this project you agree to abide by its terms.

### License

```
Copyright 2019 Province of British Columbia

Licensed under the Apache License, Version 2.0 (the &quot;License&quot;);
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an &quot;AS IS&quot; BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and limitations under the License.
```

This repository is maintained by [Data Science & Analytics Branch (OCIO) ](https://github.com/orgs/bcgov/teams/dsab).

---
*This project was created using the [bcgovr](https://github.com/bcgov/bcgovr) package.* 
