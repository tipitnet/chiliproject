require File.expand_path('../../test_helper', __FILE__)

class ApplicationHelperTest < ActionView::TestCase

  def test_replace_image_for_links
    input = "<p><img src=\"http://localhost:3000/attachments/download/68\" alt=\"\" /></p>"
    result = replace_images_for_links(input, nil)
    assert_equal("<p>[Inline Image: <a href=\"http://localhost:3000/attachments/download/68\">link</a> ]</p>", result)
  end

  def test_replace_image_for_links_not_affect_when_no_img
    input = '<p>Hello world</p>'
    result = replace_images_for_links(input, nil)
    assert_equal(input, result)
  end

end