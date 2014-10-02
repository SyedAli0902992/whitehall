# encoding: utf-8

require 'test_helper'

class HtmlAttachmentTest < ActiveSupport::TestCase
  test '#body attribute is delegated to GovspeakContent' do
    attachment = HtmlAttachment.new

    attachment.body = 'Govspeak body'

    assert_equal 'Govspeak body', attachment.body
    assert attachment.govspeak_content
    assert_equal attachment.body, attachment.govspeak_content.body
  end

  test 'validates that a body is provided' do
    attachment = build(:html_attachment, body: nil)

    refute attachment.valid?
    assert_equal ["can't be blank"], attachment.errors[:body]
  end

  test '#url returns absolute path' do
    edition = create(:published_publication, :with_html_attachment)
    attachment = edition.attachments.first
    expected = "/government/publications/#{edition.slug}/#{attachment.slug}"
    assert_equal expected, attachment.url
  end

  test "slug is copied from previous edition's attachment" do
    edition = create(:published_publication, attachments: [
      attachment = build(:html_attachment, title: "an-html-attachment")
    ])
    draft = edition.create_draft(create(:policy_writer))

    assert_equal "an-html-attachment", draft.attachments.first.slug
  end

  test "slug is updated when the title is changed if edition is unpublished" do
    edition = create(:draft_publication, attachments: [
      attachment = build(:html_attachment, title: "an-html-attachment")
    ])

    attachment.title = "a-new-title"
    attachment.save
    attachment.reload

    assert_equal "a-new-title", attachment.slug
  end

  test "slug is not updated when the title is changed if edition is published" do
    edition = create(:published_publication, attachments: [
      build(:html_attachment, title: "an-html-attachment")
    ])
    draft = edition.create_draft(create(:policy_writer))
    attachment = draft.attachments.first

    attachment.title = "a-new-title"
    attachment.save
    attachment.reload

    assert_equal "an-html-attachment", attachment.slug
  end

  test "slug is not created for non-english attachments" do
    # Additional attachment to ensure the duplicate detection behaviour isn't triggered
    create(:html_attachment, locale: "fr")
    attachment = create(:html_attachment, locale: "ar", title: "المملكة المتحدة والمملكة العربية السعودية")

    assert_blank attachment.slug
    assert_equal attachment.id.to_s, attachment.to_param
  end

  test "slug is created for english-only attachments" do
    attachment = create(:html_attachment, locale: "en", title: "We have a bias for action")

    expected_slug = "we-have-a-bias-for-action"
    assert_equal expected_slug, attachment.slug
    assert_equal expected_slug, attachment.to_param
  end

  test "slug is cleared when changing from english to non-english" do
    attachment = create(:html_attachment, locale: "en")

    attachment.update_attributes!(locale: "fr")
    assert_blank attachment.slug
  end
end
