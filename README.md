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

## Supported statuses
Each configuration item can be rendered differently. The style depends on the "project" attribute value.
Following values are supported:

| property value | supported by   | result                                                       |
|----------------|----------------|--------------------------------------------------------------|
| \<absent\>     | landscape2 app | the item will be rendered as usual, small icon size, colored |
| graduated      | landscape2 app | big icon size, colored                                       |
| sandbox        | landscape2 app | small icon size, colored                                     |
| archived       | landscape2 app | small icon size, gray-colored                                |
| reject         | conf-processor | small icon size, colored, covered with red cross             |
So, "sandbox" and "\<absent\>" are rendered similar. The difference is - that "sandbox"-ed item has "SANDBOX" label and may be quickly filtered.

See example below: <br>
![](./docs/prj_types.png)

## Deployment
All commits to "main" branch are automatically deployed to production instance. Approximate deployment time is ~one minute. 
