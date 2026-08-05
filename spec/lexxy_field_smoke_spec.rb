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
