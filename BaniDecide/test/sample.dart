library test.sample;

import"dart:html";

void main() {
  DivElement d = querySelector('.fb-comments');
  d.dataset['href'] = 'http://localhost/index.html';
}
