# qubership-landscape-config
This project extends/overrides base configuration of CNCF landscape https://github.com/cncf/landscape

## Project Structure
### added_logos
Folder to contain additional icons in SVG format. In case files exist with same name as
in the base configuration repository https://github.com/cncf/landscape/tree/master/hosted_logos then
icon from this repository will be used instead of base file.

### added_items
folder to contain additional configuration items in YAML format (*.yml).
The structure of content of the file must be same as base configuration file https://github.com/cncf/landscape/blob/master/landscape.yml

File can be organized into subfolders. During processing they will be collected recursively and will be merged
into base landscape.yml file.
All new configuration items will be added. All items which suites by category + subcategory + name will override
corresponding base configuration item properties.

