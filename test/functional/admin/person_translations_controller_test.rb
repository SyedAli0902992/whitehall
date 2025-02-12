require "test_helper"

class Admin::PersonTranslationsControllerTest < ActionController::TestCase
  setup do
    login_as_preview_design_system_user :writer
    @person = create(:person, biography: "She was born. She lived. She died.")

    Locale.stubs(:non_english).returns([Locale.new(:fr), Locale.new(:es)])
  end

  should_be_an_admin_controller

  view_test "index shows a form to create missing translations" do
    get :index, params: { person_id: @person }

    translations_path = admin_person_translations_path(@person)
    assert_select "form[action=?]", translations_path do
      assert_select "select[name=translation_locale]" do
        assert_select "option[value=fr]", text: "Français (French)"
        assert_select "option[value=es]", text: "Español (Spanish)"
      end

      assert_select "button[type=submit]"
    end
  end

  view_test "index omits existing translations from create select" do
    person = create(
      :person,
      biography: "She was born. She lived. She died.",
      translated_into: {
        fr: {
          biography: "Elle est née. Elle a vécu. Elle est morte.",
        },
      },
    )

    get :index, params: { person_id: person }

    assert_select "select[name=translation_locale]" do
      assert_select "option[value=fr]", count: 0
    end
  end

  view_test "index omits create form if no missing translations" do
    person = create(
      :person,
      biography: "She was born. She lived. She died.",
      translated_into: {
        fr: {
          biography: "Elle est née. Elle a vécu. Elle est morte.",
        },
        es: {
          biography: "Ella nació. Ella vivía. Ella murió.",
        },
      },
    )

    get :index, params: { person_id: person }

    assert_select "select[name=translation_locale]", count: 0
  end

  view_test "index lists existing translations" do
    person = create(
      :person,
      biography: "She was born. She lived. She died.",
      translated_into: {
        fr: {
          biography: "Elle est née. Elle a vécu. Elle est morte.",
        },
      },
    )

    get :index, params: { person_id: person }

    edit_translation_path = edit_admin_person_translation_path(person, "fr")
    view_person_path = person.public_path(locale: "fr")
    assert_select "a[href=?]", edit_translation_path, text: "Edit Français"
    assert_select "a[href=?]", Plek.website_root + view_person_path, text: "(view)"
  end

  view_test "index does not list the english translation" do
    get :index, params: { person_id: @person }

    edit_translation_path = edit_admin_person_translation_path(@person, "en")
    assert_select "a[href=?]", edit_translation_path, text: "en", count: 0
  end

  view_test "index displays delete button for a translation" do
    person = create(
      :person,
      biography: "She was born. She lived. She died.",
      translated_into: {
        fr: {
          biography: "Elle est née. Elle a vécu. Elle est morte.",
        },
      },
    )

    get :index, params: { person_id: person }

    assert_select ".gem-link--destructive", text: "Delete Français", href: confirm_destroy_admin_person_translation_path(@person, :fr)
  end

  test "create redirects to edit for the chosen language" do
    post :create, params: { person_id: @person, translation_locale: "fr" }

    assert_redirected_to edit_admin_person_translation_path(@person, id: "fr")
  end

  view_test "edit indicates which language is being translated to" do
    create(:person, translated_into: [:fr])
    get :edit, params: { person_id: @person, id: "fr" }

    assert_select "h1", text: "Edit ‘Français(French)’ translation for: #{@person.name}"
  end

  view_test "edit presents a form to update an existing translation" do
    person = create(
      :person,
      translated_into: {
        fr: {
          biography: "Elle est née. Elle a vécu. Elle est morte.",
        },
      },
    )

    get :edit, params: { person_id: person, id: "fr" }

    translation_path = admin_person_translation_path(person, "fr")
    assert_select "form[action=?]", translation_path do
      assert_select "textarea[name='person[biography]']", text: "Elle est née. Elle a vécu. Elle est morte."
      assert_select "button[type=submit]", text: "Save"
    end
  end

  view_test "edit form adds right-to-left class and dir attribute for text field and areas in right-to-left languages" do
    person = create(
      :person,
      translated_into: {
        ar: {
          biography: "ولدت. عاشت. توفيت.",
        },
      },
    )

    get :edit, params: { person_id: person, id: "ar" }

    translation_path = admin_person_translation_path(person, "ar")
    assert_select "form[action=?]", translation_path do
      assert_select "textarea[name='person[biography]'][dir='rtl']", text: "ولدت. عاشت. توفيت."
      assert_select "button[type=submit]", text: "Save"
    end
  end

  view_test "update updates translation and redirects back to the index" do
    put :update,
        params: {
          person_id: @person,
          id: "fr",
          person: {
            biography: "Elle est née. Elle a vécu. Elle est morte.",
          },
        }

    @person.reload
    with_locale :fr do
      assert_equal "Elle est née. Elle a vécu. Elle est morte.", @person.biography
    end
    assert_redirected_to admin_person_translations_path(@person)
  end

  test "destroy removes translation and redirects to list of translations" do
    person = create(:person, translated_into: [:fr])

    Sidekiq::Testing.inline! do
      delete :destroy, params: { person_id: person, id: "fr" }
    end

    assert_publishing_api_discard_draft(person.content_id, locale: "fr")
    assert_publishing_api_unpublish(person.content_id, request_json_includes(locale: "fr"))

    person.reload

    assert_not person.translated_locales.include?(:fr)
    assert_redirected_to admin_person_translations_path(person)
  end
end
