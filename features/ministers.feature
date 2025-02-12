Feature: Minister pages
  As a citizen
  I want to be able to view a page gathering information about a minister
  So that I can see what government activities they are involved with
  As the No 10/Cabinet Office digital team
  We want curate the order in which ministers are listed in the Cabinet
  section of the ministers page and in the whips section
  So that the seniority of members of cabinet and whips are accurately
  reflected

  Scenario: Viewing all ministers
    Given "Johnny Macaroon" is the "Minister of Crazy" for the "Department of Woah"
    And "Fred Bloggs" is the "Minister of Sane" for the "Department of Foo"
    When I visit the ministers page
    Then I should see that "Johnny Macaroon" is a minister in the "Department of Woah"
    And I should see that "Fred Bloggs" is a minister in the "Department of Foo"

  Scenario: Ministers show only once even if they have two roles
    Given "Johnny Macaroon" is the "Minister of Crazy" for the "Department of Woah"
    And "Johnny Macaroon" is the "Minister of Fun" for the "Department of Woah"
    When I visit the ministers page
    Then I should see that "Johnny Macaroon" is a minister in the "Department of Woah" with role "Minister of Crazy, Minister of Fun"

  Scenario: Viewing ministers and whips
    Given "Johnny Macaroon" is the "Minister of Crazy" for the "Department of Woah"
    And "Fred Bloggs" is a commons whip "Deputy Chief Whip, Comptroller of HM Household" for the "Department of Foo"
    When I visit the ministers page
    Then I should see that "Johnny Macaroon" is a minister in the "Department of Woah"
    And I should see that "Fred Bloggs" is a commons whip "Deputy Chief Whip, Comptroller of HM Household"

  Scenario: Viewing ministers and ministers that also attend cabinet
    Given "Johnny Macaroon" is the "Minister of Crazy" for the "Department of Woah"
    And "Fred Bloggs" is the "Minister of Sane" for the "Department of Foo" and also attends cabinet
    When I visit the ministers page
    Then I should see that "Johnny Macaroon" is a minister in the "Department of Woah"
    And I should see that "Fred Bloggs" also attends cabinet
    And I should see that "Fred Bloggs" is a minister in the "Department of Foo"

  Scenario: Administering the order of cabinet ministers
    Given I am a GDS editor called "Jane"
    And two cabinet ministers "Mary Moffet" and "Catherine Tuffet"
    When I order the cabinet ministers "Mary Moffet", "Catherine Tuffet"
    Then I should see "Mary Moffet", "Catherine Tuffet" in that order on the ministers page
    When I order the cabinet ministers "Catherine Tuffet", "Mary Moffet"
    Then I should see "Catherine Tuffet", "Mary Moffet" in that order on the ministers page

  Scenario: Administering the order of whips
    Given I am a GDS editor called "Jane"
    Given two whips "Wilma the Whip" and "Jake the Junior Whip"
    When I order the whips "Wilma the Whip", "Jake the Junior Whip"
    Then I should see "Wilma the Whip", "Jake the Junior Whip" in that order on the whips section of the ministers page
    When I order the whips "Jake the Junior Whip", "Wilma the Whip"
    Then I should see "Jake the Junior Whip", "Wilma the Whip" in that order on the whips section of the ministers page
