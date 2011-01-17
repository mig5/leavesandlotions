<?php

/**
 * Return a description of the profile for the initial installation screen.
 *
 * @return
 *   An array with keys 'name' and 'description' describing this profile.
 */
function leavesandlotions_profile_details() {
  return array(
    'name' => 'mig5.net',
    'description' => 'Select this profile to deploy an instance of mig5.net.'
  );
}

/**
 * Return an array of the modules to be enabled when this profile is installed.
 *
 * @return
 *  An array of modules to be enabled.
 */
function leavesandlotions_profile_modules() {
  return array(
    // Optional core
    'comment', 'contact', 'dblog', 'help', 'menu',
    'path', 'php', 'search', 'taxonomy', 'trigger', 'update',
    // Contrib
    'content', 'number', 'optionwidgets', 'text', 'filefield',
    'imageapi', 'imageapi_gd', 'imagefield', 'install_profile_api', 'views', 'views_ui',
    'admin_menu', 'captcha', 'recaptcha', 'lightbox2',
    'taxonomy_image', 'taxonomy_image_blocks', 'taxonomy_image_node_display',
    'token', 'pathauto', 'xmlsitemap', 'xmlsitemap_node', 'xmlsitemap_engines',
    'jquery_update', 
  );
}

/**
* Implementation of hook_profile_tasks().
*/
function leavesandlotions_profile_tasks() {

  // Install the core required modules and our extra modules
  $core_required = array('block', 'filter', 'node', 'system', 'user');
  install_include(array_merge(leavesandlotions_profile_modules(), $core_required));

  // Make a 'client admin' role
  install_add_role('client admin');
  $rid = install_get_rid('client admin');
  // Set some permissions for the role
  $perms = array(
    'access administration menu',
    'access comments',
    'administer comments',
    'post comments',
    'post comments without approval',
    'access site-wide contact form',
    'access content',
    'administer nodes',
    'create page content',
    'create product content',
    'edit any page content',
    'edit any product content',
    'edit own page content',
    'edit own product content',
    'search content',
    'use advanced search',
    'access administration pages',
  );

  install_add_permissions($rid, $perms);


  // Change anonymous user's permissions - since anonymous user is always rid 1 we don't need to retrieve it
  $perms = array(
    'access content', 
    'access comments', 
    'post comments',
    'access site-wide contact form',
    'search content',
    'use advanced search',
    'access taxonomy images',
  );

  install_add_permissions(1, $perms);


  // Insert default user-defined node types into the database. For a complete
  // list of available node type attributes, refer to the node type API
  // documentation at: http://api.drupal.org/api/HEAD/function/hook_node_info.
  $types = array(
    array(
      'type' => 'page',
      'name' => st('Page'),
      'module' => 'node',
      'description' => st("A <em>page</em>, similar in form to a <em>story</em>, is a simple method for creating and displaying information that rarely changes, such as an \"About us\" section of a website. By default, a <em>page</em> entry does not allow visitor comments and is not featured on the site's initial home page."),
      'custom' => TRUE,
      'modified' => TRUE,
      'locked' => FALSE,
      'help' => '',
      'min_word_count' => '',
    ),
    array(
      'type' => 'product',
      'name' => st('Product'),
      'module' => 'node',
      'description' => st("A product for the catalogue"),
      'custom' => TRUE,
      'modified' => TRUE,
      'locked' => FALSE,
      'help' => '',
      'min_word_count' => '',
    ),
    array(
      'type' => 'story',
      'name' => st('Story'),
      'module' => 'node',
      'description' => st("A <em>story</em>, similar in form to a <em>page</em>, is ideal for creating and displaying content that informs or engages website visitors. Press releases, site announcements, and informal blog-like entries may all be created with a <em>story</em> entry. By default, a <em>story</em> entry is automatically featured on the site's initial home page, and provides the ability to post comments."),
      'custom' => TRUE,
      'modified' => TRUE,
      'locked' => FALSE,
      'help' => '',
      'min_word_count' => '',
    ),
  );

  foreach ($types as $type) {
    $type = (object) _node_type_set_defaults($type);
    node_type_save($type);
  }

  // Generally, all nodes default to _not_ promoted to front page and
  // attachments/comments disabled
  variable_set('node_options_story', array('status'));
  variable_set('comment_story', 0);
  variable_set('upload_story', 0);
  variable_set('node_options_page', array('status'));
  variable_set('comment_page', 0);
  variable_set('upload_page', 0);
  variable_set('node_options_product', array('status'));
  variable_set('comment_product', 0);
  variable_set('upload_product', 0);
  // File: disable attachments
  variable_set('upload_file', 0);

  // Don't let users register
  variable_set('user_register', '0');

  // Don't display date and author information for page nodes by default.
  $theme_settings = variable_get('theme_settings', array());
  $theme_settings['toggle_node_info_page'] = FALSE;
  $theme_settings['toggle_node_info_story'] = FALSE;
  $theme_settings['toggle_node_info_product'] = FALSE;
  variable_set('theme_settings', $theme_settings);

  // Set default primary links

  install_menu_create_menu_item('contact', 'Contact', '', 'primary-links');

  // Set a contact category to enable the contact form
  // Get the client e-mail from the provision
  $client_email = drush_get_option('client_email');

  install_contact_add_category('Contact', $client_email, $reply = '', $weight = 0, $selected = 1);

  // Enable default theme
  install_default_theme("scruffy");

  // Put the navigation block in the sidebar because the sidebar looks awesome.
  install_init_blocks();
  // Navigation
  install_set_block('user', 1, 'scruffy', 'right', $weight = '-10');
  install_set_block('views', 'featured_item-block_1', 'scruffy', 'right', $weight = '-9');
  install_set_block('block', 8, 'scruffy', 'right', $weight = '-8', $title = 'Order Form');
}

