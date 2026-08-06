# Smoke spec for avo-lexxy_field.
#
# This gem has no test harness of its own. To run this spec, add the gem to
# external/avo's Gemfile (path: "../avo-lexxy_field"), switch a rich text
# field to `as: :lexxy` on the Playground resource, copy this file into
# external/avo/spec/requests/avo/ and run it with rspec.
require "rails_helper"

RSpec.describe "Lexxy field", type: :request do
  let(:admin_user) { create :user, roles: {admin: true} }
  let(:playground) { Playground.create!(name: "Lexxy test", trix_content: "<h1>Hello</h1><p>from lexxy</p>") }

  before do
    login_as admin_user
  end

  it "renders the lexxy editor on edit" do
    get "/admin/resources/playgrounds/#{playground.id}/edit"

    expect(response.status).to eq 200
    expect(response.body).to include "<lexxy-editor"
    expect(response.body).to include "data-direct-upload-url"
    expect(response.body).to include "data-blob-url-template"
    expect(response.body).to include 'name="playground[trix_content]"'
  end

  # Run this one with the field declared as
  # `field :trix_content, as: :lexxy, markdown: false, headings: %w[h2 h3], preset: :comment`.
  it "renders the editor options as element attributes" do
    get "/admin/resources/playgrounds/#{playground.id}/edit"

    expect(response.body).to include 'markdown="false"'
    expect(response.body).to include 'headings="[&quot;h2&quot;,&quot;h3&quot;]"'
    # A preset is a plain name, not JSON — Lexxy reads it off the element raw.
    expect(response.body).to include 'preset="comment"'
  end

  # The editor needs the whole row, not the narrow content column a side-by-side
  # wrapper leaves it. `full_width` alone only widens within that column.
  it "stacks the wrapper by default" do
    get "/admin/resources/playgrounds/#{playground.id}/edit"

    expect(response.body).to include "field-wrapper--stacked"
  end

  it "renders the media library button pointing back at this field" do
    get "/admin/resources/playgrounds/#{playground.id}/edit"

    expect(response.body).to include 'data-controller="lexxy-field"'
    expect(response.body).to match(/attach-media\?controller_name=lexxy-field/)
    expect(response.body).to match(/controller_selector=.*unique-selector/)
  end

  it "renders the content on show" do
    get "/admin/resources/playgrounds/#{playground.id}"

    expect(response.status).to eq 200
    expect(response.body).to include "lexxy-content"
    expect(response.body).to include "from lexxy"
  end

  it "updates the action text attribute on submit" do
    patch "/admin/resources/playgrounds/#{playground.id}", params: {
      playground: {trix_content: "<p>updated with <strong>lexxy</strong></p>"}
    }

    expect(playground.reload.trix_content.to_plain_text).to include "updated with lexxy"
  end
end
