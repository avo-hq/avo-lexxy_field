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
| `always_show` | `false` | Show the full content on the show view instead of the collapsed More/Less preview. |
| `attachments_disabled` | `false` for Action Text attributes, `true` otherwise | Disable file attachments. Lexxy uploads through Active Storage direct uploads and relies on Action Text to attach the blobs, so plain columns have attachments disabled by default to avoid orphaned blobs. |

### Editor configuration

Lexxy's [editor options](https://lexxy.dev/docs/) are field options too. They land on the `<lexxy-editor>` element, which is where Lexxy reads them from:

```ruby
field :body, as: :lexxy,
  preset: :comment,
  markdown: false,
  headings: %w[h2 h3],
  permitted_attachment_types: %w[image/png image/jpeg]
```

| Option | Description |
| ------ | ----------- |
| `preset` | Name of a preset registered with `Lexxy.configure`. |
| `markdown` | Markdown shortcuts while typing. |
| `rich_text` | Rich text at all — `false` gives you a plain text editor. |
| `multi_line` | Whether Enter creates a new paragraph. |
| `headings` | Heading levels the toolbar offers. |
| `toolbar` | Toolbar configuration. |
| `highlight` | Highlight colors. |
| `permitted_attachment_types` | Content types accepted for upload. |

Anything that isn't a string is passed as JSON, which is what Lexxy parses it back from. Use `attachments_disabled` rather than Lexxy's `attachments` — it also hides the media library button.

To configure Lexxy globally — presets, extensions, `attachmentTagName` — call `Lexxy.configure` when this gem's bundle announces itself. Avo's layout doesn't load your app's JavaScript, and Lexxy defines its elements immediately after this bundle runs, so the callback is the only point early enough:

```erb
<%# app/views/avo/partials/_head.html.erb %>
<script>
  document.addEventListener("avo:lexxy:configure", (event) => {
    event.detail.configure({
      comment: {markdown: true, headings: ["h3"], toolbar: {upload: "file"}},
      global: {authenticatedUploads: true}
    })
  })
</script>
```

### Media Library

When Avo's [Media Library](https://docs.avohq.io/4.0/media-library.html) is enabled, the toolbar gets a button that opens the library in a modal. Picking an asset inserts it into the content — images as Action Text attachments, other files as links. The button is hidden when the field has attachments disabled.

## Development

```bash
yarn install
yarn build
```

The built assets in `app/assets/builds/` are committed and shipped with the gem.
