# dvtf-pingctl

> [!CAUTION]
> ## ⚠️ This project is no longer maintained
>
> **`dvtf-pingctl` has been superseded and is archived.**
>
> This tool has been replaced by the DaVinci capability built into the [PingOne Terraform provider](https://registry.terraform.io/providers/pingidentity/pingone/latest), accessible via the **[`pingcli-plugin-terraformer`](https://github.com/pingidentity/pingcli-plugin-terraformer)** plugin for the [Ping CLI](https://github.com/pingidentity/pingcli).
>
> Please migrate to that tooling. No further updates will be made to this repository.

A simple CLI tool to assist HCL generation and debugging with using the [DaVinci Terraform provider](https://registry.terraform.io/providers/pingidentity/davinci/latest).

* Supported DaVinci Terraform provider version: `v0.5.0+`
* Requires Terraform CLI version: `v1.12.0+`

## Install

Only Homebrew is supported initially, for other methods of install please [raise an issue](https://github.com/patrickcping/dvtf-pingctl/issues/new?title=New%20installation%20method%20required).

### Homebrew

```shell
brew tap patrickcping/dvtf-pingctl
brew install dvtf-pingctl
```

Test the installation with:

```shell
dvtf-pingctl --help
```

## Example Usage

Visit the [example](./example/) to view a full example of generation and validation starting with a multi-flow export.

## Using `--help`

Help can found by using the `--help` / `-h` parameter for any command.

Examples:

```shell
dvtf-pingctl generate --help
dvtf-pingctl validate --help
```

## Providing the Export File

The DaVinci exports can be provided in one of two ways:
- By defining the `exportFilePath` in the YAML config file.  Multiple files can be specified.
- By using the `--export-file-path` / `-e` parameter.  Multiple files can be specified.
- Piping the output of a command to the `dvtf-pingctl` tool.  Only one JSON payload is accepted.

### Providing the Export file(s) by CLI Parameter

The `--export-file-path` / `-e` parameter can be used to specify the path locations of one or more files.  If multiple files are provided, the tool will validate all provided files at once (if using the `dvtf-pingctl validate ...` command) or generate a single set of Terraform `.tf` files with combined HCL definitions (if using the `dvtf-pingctl generate ...` command)

Examples:

```shell
dvtf-pingctl generate \
  --export-file-path /path/to/my/export.json
```
```shell
dvtf-pingctl generate \
    -e /path/to/my/export.json
```
```shell
dvtf-pingctl generate \
    --export-file-path /path/to/my/main_flow_export.json \
    --export-file-path /path/to/my/sub_flow_export.json
```
```shell
dvtf-pingctl generate \
    -e /path/to/my/main_flow_export.json \
    -e /path/to/my/sub_flow_export.json
```
```shell
dvtf-pingctl validate \
    --export-file-path /path/to/my/export.json \
    --export-file-path /path/to/my/sub_flow_export.json
```

### Providing the Export JSON through Pipe

A single DaVinci export JSON payload can be piped to the `dvtf-pingctl` command, useful if using `jq` to modify the payload before generation/validation.

Examples:

```shell
cat /path/to/my/export.json | dvtf-pingctl generate
```
```shell
jq '.name = "abcde"' ./path/to/my/export.json | dvtf-pingctl generate
```
```shell
jq '.name = "abcde"' ./path/to/my/export.json | dvtf-pingctl validate
```

## Terraform HCL Config Generation

Generate HCL configuration from a DaVinci service JSON export file using the `dvtf-pingctl generate ...` command.  The command will generate a Terraform module by default, with variables for connector properties and variable values.

### Specifying an Output Path

The output path for generated resources can be set with the `--output-path` / `-o` parameter on the `dvtf-pingctl generate ...` command.  The default, if not provided, is `./generated`, meaning it will create a directory `generated` in the current working directory.

If the output directory already exists and the `--overwrite` parameter is not set, the generator will return an error.  If you want to overwrite the contents of the output directory, use the `--overwrite` parameter.

Examples:

```shell
dvtf-pingctl generate \
    --export-file-path /path/to/my/export.json \
    -o ./my/output/dir
```
```shell
dvtf-pingctl generate \
    -e /path/to/my/export.json \
    -o ./my/output/dir
```
```shell
dvtf-pingctl generate \
    --export-file-path /path/to/my/export.json \
    -o ./my/output/dir \
    --overwrite
```
```shell
dvtf-pingctl generate \
    -e /path/to/my/export.json \
    -o ./my/output/dir \
    --overwrite
```

Examples where the JSON payload is provided via pipe:

```shell
cat /path/to/my/export.json | dvtf-pingctl generate -o ./my/output/dir
```
```shell
cat /path/to/my/export.json | dvtf-pingctl generate -o ./my/output/dir --overwrite
```

### Generating Specific Resources

Only `davinci_flow`, `davinci_variable`, and `davinci_connector` resources from the DaVinci Terraform provider are supported and can be generated.

Individual resources can be selected for generation using the `--resource` flag (`-r` for short), and if this flag is omitted, all resources will be generated.  The flag can be repeated as many times as .needed

Examples where the JSON is provided as a parameter:

```shell
dvtf-pingctl generate \
    --export-file-path /path/to/my/export.json \
    -o ./my/output/dir \
    --resource davinci_flow \
    --resource davinci_variable \
    --resource davinci_connector
```
```shell
dvtf-pingctl generate \
    -e /path/to/my/export.json \
    -o ./my/output/dir \
    -r davinci_flow \
    -r davinci_variable \
    -r davinci_connector
```

Examples where the JSON payload is provided via pipe:

```shell
cat /path/to/my/export.json | dvtf-pingctl generate -o ./my/output/dir
```
```shell
cat /path/to/my/export.json | dvtf-pingctl generate -o ./my/output/dir --resource davinci_flow --resource davinci_variable --resource davinci_connector
```
```shell
cat /path/to/my/export.json | dvtf-pingctl generate -o ./my/output/dir -r davinci_flow -r davinci_variable -r davinci_connector
```

## Flow Validation (for use with the `davinci_flow` Terraform resource)

Use the `dvtf-pingctl validate ...` command to ensure that the flow validates correctly when used with the DaVinci Terraform provider (version `v0.4.2+`).  The `validate` command will show more detail than the Terraform provider validation, and can be used to debug errors and warnings on `terraform plan ...` and `terraform apply ...`

The Terraform provider expects single flows only, and this command contains a validation step to ensure that only one flow is provided in the JSON export contents.

Examples where the JSON is provided as a parameter:

```shell
dvtf-pingctl validate \
    --export-file-path /path/to/my/export.json
```
```shell
dvtf-pingctl validate \
    -e /path/to/my/export.json
```

Example where the JSON is provided via pipe:

```shell
cat /path/to/my/export.json | dvtf-pingctl validate
```

### Validating for a Specific Terraform Resource Field (Advanced State Debugging)

To validate the JSON input for a specific `davinci_flow` field in the case of debugging state, use the `--field` flag (`-f` for short):

Examples where the JSON is provided as a parameter:

```shell
dvtf-pingctl validate \
    --export-file-path /path/to/my/export.json \
    --field flow_configuration_json
```
```shell
dvtf-pingctl validate \
    -e /path/to/my/export.json \
    -f flow_configuration_json
```

Example where the JSON is provided via pipe:

```shell
cat /path/to/my/export.json | dvtf-pingctl validate --field flow_configuration_json
```
```shell
cat /path/to/my/export.json | dvtf-pingctl validate -f flow_configuration_json
```

### Return Codes

The `dvtf-pingctl validate ...` command will return the following return status codes along with a text description of the validation issues:

- `0` - Successful validation, no warnings
- `1` - Unsuccessful validation
- `2` - Successful validation, with warnings

## Logging

The logging level can be set using the `DVTF_LOG` environment variable.  The possible values that can be set are `DEBUG`, `INFO`, `WARN`, `ERROR` and `NOLEVEL`.  By default, extra log output is disabled.

A log file can be created using the `DVTF_PATH` environment variable.  This redirects the log output to a file of choice.  If not set, the debug output will be printed alongside the command output (stdout).

The following example logs debug output to the file called `dvtf.log`:
```shell
DVTF_LOG=DEBUG DVTF_PATH=`pwd`/dvtf.log dvtf-pingctl validate \
    --export-file-path /path/to/my/export.json \
    --field flow_configuration_json
```

## Configuration File

The parameters described above can be configured in a static configuration file, expected to be named `.dvtf-pingctl.yaml` in the same directory that the CLI tool is run.  The following describe the properties that can be set, and an example can be found at [./dvtf-pingctl.yaml.example](./blob/main/.dvtf-pingctl.yaml.example)

#### General Properties

The following are configuration file settings for both `dvtf-pingctl generate ...` and `dvtf-pingctl validate ...` commands.

| Config File Property | Type          | Equivalent Parameter        | Purpose                                                               |
|----------------------|---------------|-----------------------------|-----------------------------------------------------------------------|
| `exportFilePath`     | array / list  | `--export-file-path` / `-e` | Defines the list of JSON files to process                             |

#### Generate Properties

The following are configuration file settings for the `dvtf-pingctl generate ...` command.

| Config File Property    | Type          | Equivalent Parameter        | Purpose                                                                                                                                                 |
|-------------------------|---------------|-----------------------------|---------------------------------------------------------------------------------------------------------------------------------------------------------|
| `generate.resource`     | array / list  | `--resource` / `-r`         | Defines the list of resources to generate HCL for.  Defaults to all resources.  Options are `davinci_flow`, `davinci_variable` and `davinci_connection` |
| `generate.outputPath`   | text          | `--output-path` / `-o`      | Defines the output directory to which generated files will be saved.  Defaults to `./generated`                                                         |
| `generate.overwrite `   | boolean       | `--overwrite`               | Specifies whether to overwrite previously generated files in the output directory path.  Defaults to `false`                                            |

#### Validate Properties

The following are configuration file settings for the `dvtf-pingctl validate ...` command.

| Config File Property    | Type | Equivalent Parameter | Purpose                                                                                                                                                      |
|-------------------------|------|----------------------|--------------------------------------------------------------------------------------------------------------------------------------------------------------|
| `validate.field`        | text | `--field` / `-f`     | Defines the field that the JSON should be validated for.  Defaults to `flow_json`.  Options are `flow_json`, `flow_export_json` or `flow_configuration_json` |

## Limitations / TODO

- `davinci_connector` `property` blocks are not yet generated and must be defined using the [DaVinci Connector Definitions guide](https://registry.terraform.io/providers/pingidentity/davinci/latest/docs/guides/connector-reference)
- Homebrew is the only installer currently.  Multi-arch install (including Windows) TBD
- Housekeeping: Enhanced Debug logging
- Housekeeping: Unit Testing