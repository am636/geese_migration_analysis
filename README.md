# Greater White-fronted Geese Migration Analysis Codes

[![DOI](https://zenodo.org/badge/DOI/10.5281/zenodo.15358009.svg)](https://doi.org/10.5281/zenodo.15358009)

*Code and workflow for multi-modal navigation analysis in migratory greater white-fronted geese*

---

## Overview

This repository contains the scripts and workflows used in the study titled **"Multi-modal, interrelated navigation in migratory birds: A data mining study"**. The workflow includes preprocessing GPS tracking data, annotating it with environmental and geomagnetic variables, clustering the data, and interpreting the results through statistical and visual analyses. The repository is designed to support reproducibility of the methods described in the associated paper.

## Data availability

The processed GPS-tracking dataset is available on Zenodo: [10.5281/zenodo.15458188](https://doi.org/10.5281/zenodo.15458188) under a CC-BY 4.0 licence.

The complete analysis workflow, including R and Python scripts, is archived on Zenodo: [10.5281/zenodo.15358009](https://doi.org/10.5281/zenodo.15358009) under an MIT licence, and mirrored on GitHub at [BEGIN-StAndrews/geese_migration_analysis](https://github.com/BEGIN-StAndrews/geese_migration_analysis).

Raw GPS data originate from five Movebank studies and remain available under their original terms:

- `127892189`
- `408961322`
- `13183695`
- `180156318`
- `44083081`

## Repository structure

### 1. Preprocessing

This folder contains scripts for cleaning and organising raw GPS tracking data, including removing errors, aggregating datasets, isolating active migratory flight data, and segmenting data into seasonal datasets. The preprocessing workflow reflects the steps described in the paper but is not required for users downloading the final dataset.

### 2. Annotation

This folder annotates preprocessed data with environmental variables, including:

- wind conditions from ERA5 datasets
- coastal proximity data from NASA's Distance to Coast dataset
- elevation data from ASTER GDEM dataset

Geomagnetic data annotation uses the [MagGeo repository](https://github.com/MagGeo/MagGeo), available separately on GitHub. Refer to the MagGeo repository for detailed geomagnetic data extraction methods.

### 3. Autumn and 4. Spring

These folders contain workflows for seasonal analyses of autumn and spring migration data. Processes include movement-parameter calculations, clustering-feature extraction, and statistical analyses. Users of the final dataset can refer directly to these workflows for analysis without repeating preprocessing steps.

Key steps include:

- processing annotated GPS data
- classifying day and night data points
- calculating wind support, crosswind, and geomagnetic parameters such as apparent angle of geomagnetic inclination
- extracting clustering features based on changes in environmental and geomagnetic cues to study behavioural patterns
- performing statistical analyses and generating visualisations to interpret results

### 5. Clustering

This folder evaluates clustering solutions and performs agglomerative hierarchical clustering (AHC). Outputs include dendrograms, cluster IDs, and validation metrics such as Silhouette and Calinski-Harabasz indices.

## Requirements

- **R packages:** `tidyverse`, `move`, `maptools`
- **Python libraries:** `numpy`, `pandas`, `scipy`, `sklearn`

## Citation

If you use this code or workflow, please cite both the associated paper and the archived code release.

**Associated paper**

Moayedi, A., Long, J. A., Kölzsch, A., Kruckenberg, H., Benitez-Paez, F., & Demšar, U. (2025). Multi-modal, interrelated navigation in migratory birds: A data mining study. *Ecological Informatics*, 90, 103218. https://doi.org/10.1016/j.ecoinf.2025.103218

**Processed GPS-tracking dataset**

Kölzsch, A., Moayedi, A., Moonen, S., Müskens, G. J. D. M., Glazov, P., Wikelski, M., & Kruckenberg, H. (2025). Data from: Multi-modal, interrelated navigation in migratory birds: A data mining study. Zenodo. https://doi.org/10.5281/zenodo.15458188

**Archived code release**

Moayedi, A., Long, J. A., Kölzsch, A., Kruckenberg, H., Benitez-Paez, F., & Demšar, U. (2025). Greater White-fronted Geese Migration Analysis Codes. Zenodo. https://doi.org/10.5281/zenodo.15358009

## Contact

Ali Moayedi  
University of St Andrews, UK  
am636@st-andrews.ac.uk
