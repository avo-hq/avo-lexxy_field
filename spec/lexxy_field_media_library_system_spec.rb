# System spec for the media library integration of avo-lexxy_field.
#
# This gem has no test harness of its own. To run it, add the gem to
# external/avo's Gemfile (path: "../avo-lexxy_field"), switch a rich text
# field to `as: :lexxy` on the Playground resource, copy this file into
# external/avo/spec/system/avo/group_1/ and run it with rspec.
require "rails_helper"

RSpec.describe "Lexxy field media library", type: :system do
  let!(:playground) { Playground.create!(name: "Lexxy media", trix_content: "<p>hello</p>") }

  let!(:blob) do
    ActiveStorage::Blob.create_and_upload!(
      io: Avo::Engine.root.join("spec", "dummy", "db", "seed_files", "dummy-image.jpg").open,
      filename: "dummy-image.jpg",
      content_type: "image/jpeg"
    )
  end

  it "attaches an image picked from the library" do
    visit "/admin/resources/playgrounds/#{playground.id}/edit"

    # The button is rendered outside the editor and moved into Lexxy's toolbar.
    expect(page).to have_css("lexxy-toolbar .lexxy-field__media-library-button")

    find(".lexxy-field__media-library-button").click
    find("[data-component='avo/media_library/list_item_component']", match: :first).click

    expect(page).to have_css("lexxy-editor figure.attachment img")

    click_on "Save"
    wait_for_loaded

    # Action Text serializes an sgid onto the blob (Rails 8.1+), so the picked
    # blob is attached to the record rather than embedded as a remote image.
    expect(playground.reload.trix_content.embeds_blobs).to include blob
  end

  it "attaches a non-image file" do
    file = ActiveStorage::Blob.create_and_upload!(
      io: StringIO.new("hello"), filename: "notes.txt", content_type: "text/plain"
    )

    visit "/admin/resources/playgrounds/#{playground.id}/edit"

    find(".lexxy-field__media-library-button").click
    find("##{ActionView::RecordIdentifier.dom_id(file)}").click

    click_on "Save"
    wait_for_loaded

    expect(playground.reload.trix_content.embeds_blobs).to include file
  end
end
