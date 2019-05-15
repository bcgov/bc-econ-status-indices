 
<a id="devex-badge" rel="Exploration" href="https://github.com/BCDevExchange/assets/blob/master/README.md"><img alt="Being designed and built, but in the lab. May change, disappear, or be buggy." style="border-width:0" src="https://assets.bcdevexchange.org/images/badges/exploration.svg" title="Being designed and built, but in the lab. May change, disappear, or be buggy." /></a>


bc-econ-status-indices
============================

A set of R scripts that use tidied Statistics Canada taxdata developed [previously](https://github.com/bcgov/statscan-taxdata-tidying) in order to generate area-based economic status indices for British Columbia.

The annual income tax data in this repository are purchased from Statistics Canada and are under [Statistics Canada Open Licence](https://www.statcan.gc.ca/eng/reference/licence). 

### Usage 

The source .csv files are tidied anonymized individual and family income tax data that are placed in the `input-data` sub-folder.  

The codes for economic indices and visualization of data are in `R` sub-folder.  

Generated graphs are stored in `output-data` subfolder. 

Insights developed from analyses of data tables are provided in rmd format in  `docs` folder.


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
This repository is maintained by [Integrated Data Division (OCIO)](https://github.com/orgs/bcgov/teams/idd).
---
*This project was created using the [bcgovr](https://github.com/bcgov/bcgovr) package.* 
