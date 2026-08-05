# avo-lexxy_field

Adds a `lexxy` field to [Avo](https://avohq.io), powered by [Lexxy](https://github.com/basecamp/lexxy) — Basecamp's modern rich text editor for Action Text, built on Meta's Lexical framework.

## Requirements

- Avo >= 4.0
- Rails >= 8.0.2 (required by the `lexxy` gem)
- Action Text (for attachments support)

## Installation

```ruby
# Gemfile
gem "avo-lexxy_field"
```

The gem depends on `lexxy`, which takes over `form.rich_text_area` in your whole app by default. If you only want Lexxy inside Avo, opt out in the host app:

```ruby
# config/application.rb (Rails 8.0/8.1 only)
config.lexxy.override_action_text_defaults = false
```

## Usage

```ruby
field :body, as: :lexxy
```

### Options

| Option | Default | Description |
| ------ | ------- | ----------- |
| `always_show` | `false` | Show the full content on the show view instead of the truncated preview. |
| `attachments_disabled` | `false` for Action Text attributes, `true` otherwise | Disable file attachments. Lexxy uploads through Active Storage direct uploads and relies on Action Text to attach the blobs, so plain columns have attachments disabled by default to avoid orphaned blobs. |

Lexxy element attributes (`markdown`, `rich-text`, `headings`, `preset`, `permitted-attachment-types`, etc.) can be passed through the field's `html` option:

```ruby
field :body, as: :lexxy, html: {edit: {input: {data: {}, classes: ""}}}
```

## Development

```bash
yarn install
yarn build
```

The built assets in `app/assets/builds/` are committed and shipped with the gem.
