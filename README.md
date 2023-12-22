Hyde Decap
==========

A Jekyll 4 plugin for setting up Decap CMS in your output directory.


Installation
------------

1. Add Hyde Decap to your Gemfile

`gem 'hyde-decap', '~> 0.1.0'`

2. Add entry to your Jekyll config under plugins

```yaml
plugins:
  - hyde_decap
  ...
```

3. Setup your configuration for Decap CMS under the `hyde_decap` property in your Jekyll config file

4. [Optional] Run Decap CMS's local backend for during development using `jekyll decap [reuse optional flags from jekyll serve]`. See more below for requirements.


Configuration
-------------

Hyde Decap comes with the following configuration. Override as necessary in your Jekyll Config

```yaml
# Default Configuration

hyde_decap:
  file_output_path: admin
  enable: true
  keep_files: true
```

> [!IMPORTANT]
> Decap CMS requires specific fields to be set in the configuration that are specific to each project. Add the additional yaml configuration under the `hyde_decap` property in your Jekyll config. An example is available in the [example directory](./example) in this repo. You can find all of the [Decap Configurations](https://decapcms.org/docs/configuration-options/) in the documentation.

`file_output_path`
: relative path from the root of your generated site to the location to place Decap CMS Admin.

`enable`
: will generate the files when enabled, otherwise will skip the process at build time

`keep_files`
: will not delete files between builds, and will reuse existing files if they match.

The Decap CMS admin includes [hithismani's responsive-decap CSS](https://github.com/hithismani/responsive-decap/) to provide a mobile friendly design.

Run Decap CMS Proxy and Jekyll Serve together
---------------------------------------------

> [!NOTE]
> This requires NodeJS 18+ to be installed along with Netlify CMS Proxy Server

You can simplify local development by utilizing the command `jekyll decap` which will run 2 processes for `jekyll serve` and `npx netlify-cms-proxy-server`

The command takes the same options as `jekyll serve` - livereload works for both your Jekyll builds and Decap.




Aknowledgements
---------------

[Decap CMS](https://decapcms.org) - MIT License
[Responsive Decap](https://github.com/hithismani/responsive-decap/) - MIT License
[Subprocess Code from Stack Overflow](http://stackoverflow.com/a/1162850/83386)
  - [ehsanul](https://stackoverflow.com/users/127219/ehsanul)
  - [funroll](https://stackoverflow.com/users/878969/funroll)
