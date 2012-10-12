Feature: editing draft news articles

Scenario: Creating a new draft news article
  Given I am a writer
  When I draft a new news article "Stubble to be Outlawed"
  Then I should see the news article "Stubble to be Outlawed" in the list of draft documents

Scenario: Submitting a draft publication to a second pair of eyes
  Given I am a writer
  And a draft news article "Stubble to be Outlawed" exists
  When I submit the news article "Stubble to be Outlawed"
  Then I should see the news article "Stubble to be Outlawed" in the list of submitted documents

Scenario: Viewing associated people on news articles not roles
  Given I am an editor
  And "Don Deputy" is the "Deputy Prime Minister" for the "Cabinet Office"
  And "Harriet Home" is the "Home Secretary" for the "Cabinet Office"
  When I publish a news article "News 1" associated with "Don Deputy"
  When there is a reshuffle and "Harriet Home" is now "Deputy Prime Minister"
  And I visit the news article "News 1"
  Then the article mentions "Don Deputy" and links to their bio page
  And the news article tag is the same as the person in the text
