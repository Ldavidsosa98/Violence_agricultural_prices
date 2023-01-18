*This is the master do-file for importing, merging and cleaning the raw data.


do "${code}1a_import.do"

do "${code}1b_clean.do"

do "${code}1c_merge.do"

do "${code}1d_variables.do"

do "${code}1e_label.do"