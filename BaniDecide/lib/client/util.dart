library client.util;

import "dart:html";

String getQuestionId(Location location) 
  => location.search.isEmpty ? null : location.search.substring(1);