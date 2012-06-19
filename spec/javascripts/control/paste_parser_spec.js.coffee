describe  "Paste Parser", ->

  it "parses the url correctly", ->
    pptest = new PasteParser("this is yahoo url : http://www.yahoo.com")
    link=pptest.format()
    expect(link).toEqual("<a href=http://www.yahoo.com>http://www.yahoo.com</a>")
    $('#jasmine_content').append(link)