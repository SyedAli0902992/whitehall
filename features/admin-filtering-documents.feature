Feature: Filtering documents by author in admin

  Scenario: Viewing only documents written by me
    Given I am a writer
    And I draft a new publication "My Publication"
    And a draft publication "Another Publication" exists
    And I visit the list of draft documents

    When I filter by author "Me"
    Then I should see the publication "My Publication"
    And I should not see the publication "Another Publication"

  Scenario: Viewing only publications written by me
    Given I am a writer
    And there is a user called "Janice"
    And "Janice" drafts a new publication "Janice's Publication"
    And I draft a new "English" language consultation "My Consultation"
    And I visit the list of draft documents

    When I filter by author "Janice"
    And I select the "Publications" edition filter
    Then I should see the publication "Janice's Publication"
    And I should not see the consultation "My Consultation"

  Scenario: Viewing only documents related to my department
    Given two organisations "Department of Thumbtacks" and "Ministry of Post-it Notes" exist
    And I am a writer in the organisation "Department of Thumbtacks"
    And a draft publication "Thumbtack Publication" was produced by the "Department of Thumbtacks" organisation
    And a draft publication "Another Publication" was produced by the "Ministry of Post-it Notes" organisation
    And I visit the list of draft documents

    When I filter by organisation "Department of Thumbtacks"
    Then I should see the publication "Thumbtack Publication"
    And I should not see the publication "Another Publication"

  @javascript
  Scenario: Using the document filter with javascript enabled
    Given two organisations "Department of Thumbtacks" and "Ministry of Post-it Notes" exist
    And I am a writer in the organisation "Department of Thumbtacks"
    And a draft publication "Thumbtack Publication" was produced by the "Department of Thumbtacks" organisation
    And a draft publication "The nocturnal habits of bluetack and why it is evil" was produced by the "Department of Thumbtacks" organisation
    And a draft publication "Another Publication" was produced by the "Ministry of Post-it Notes" organisation
    And I visit the list of draft documents

    When I filter by organisation "Department of Thumbtacks" with javascript enabled
    Then I should see the publication "Thumbtack Publication"
    And I should see the publication "The nocturnal habits of bluetack and why it is evil"
    And I should not see the publication "Another Publication"

    When I filter by title or slug "Thumbtack" with javascript enabled
    Then I should see the publication "Thumbtack Publication"
    And I should not see the publication "The nocturnal habits of bluetack and why it is evil"
    And I should not see the publication "Another Publication"
