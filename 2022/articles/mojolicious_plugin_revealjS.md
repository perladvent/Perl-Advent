Santa's elf had a problem. He had to write very fast a presentation and show it to a bunch of new elf's. The email assigning this to him was sent my Santa himself. 
The elf started to look on Metacpan and found this module: 'Mojolicious::Plugin::RevealJS'. He quickly typed the following commands:
```bash
cpanm Mojolicius Mojolicious::Plugin::RevealJS
``` 
Now he could generate an mojo lite app using:
```bash
mojo generate lite-app slide_show
```
Because the elf was trained in the ancient arts  of the elders he cloud open new file with vim and paste this code in:
```perl
#!/usr/bin/env perl
use Mojolicious::Lite -signatures;
app->static->paths(['.']);

plugin 'RevealJS';

any '/' => { template => 'presentation', layout => 'revealjs' };

app->start;
```
Then he swiftly created two folders:
```bash
mkdir templates
mkdir examples
``` 
After that the file for the presentation was generated:
```bash
vim templates/presentation.html.ep
```
Finlay he could add his first slides to the presentation using html: 
```html
<section>
  <h4> Create professional slideshows with Mojolicious::Plugin::RevealJS</h4>
  <p>by Trif Dragos</p>
</section>

<section>
  <h2>About this talk</h2>
    <ul>
    <li>Install and run a Mojolicius server</li>
    <li>Configure Mojolicious::Plugin::RevealJS</li>
    <li>Use html/MarkDown to generate content</li>
    <li>Add code snippets in your presentation</li>
    <li>Add notes visible only for the author of the presentation</li>
  </ul>
</section
```
Using the morbo command he could start the server. Only after that he was able to access the presentation on his local host:
```perl
morbo slide_show
# Web application available at http://127.0.0.1:3000
```
The time was ticking the elf need to speed things up, so instead of html tags he used  Markdown format:
```perl
%= markdown_section begin
  #### Create professional slideshows with Mojolicious::Plugin::RevealJS
% end

%= markdown_section begin
  * Install and run a Mojolicius server
  * Configure Mojolicious::Plugin::RevealJS
% end
```
For more details on how to do this in Markdown format he used this link: [Markdown-Cheatsheet](https://github.com/adam-p/markdown-here/wiki/Markdown-Cheatsheet)

Finlay he wanted to insert code snippets in his work. For this he use the 'include_code ' statement which pointed the file and the correct syntax highlight:
```perl
<section>
  <section>
    %= include_code 'examples/test.pl',  language => 'perl'
  </section>
  <section>
    %= include_code 'examples/app.js', language => 'javascript' 
  </section>
</section>

```  
Disaster the 'examples/test.pl' file has to much code in it the new elf's will be lost for ever if they see this. He opened the file and added some magic comments  in it:
```perl
use strict;
use warnings;

use lib 'lib';

use Foo;
use feature 'say';

# reveal begin object_creation
my $o = Foo->new();
# reveal end object_creation

$o->print_foo_bar();
$o->test(1);
say $o->test();

say $o->test();
```
After the 'section' key was added to the 'include_code' statement:
```perl
%= include_code 'examples/test.pl', language => 'pl', section => 'object_creation'
```
Only the line between those comments where visible in the presentation:
```perl
my $o = Foo->new();
``` 
Finally when he added  to each slide some notes:
```perl
<section>
  <h4> Create professional slideshows with Mojolicious::Plugin::RevealJS</h4>
  <p>by Trif Dragos</p>
  %= markdown_section begin
  Note:
  my notes
  %end
</section>
```
Now when he pressed 's' he could see the notes from each slide in new window will which also allowed him to control his presentation .

Bibliography:
https://www.perl.com/article/94/2014/6/6/Create-professional-slideshows-in-seconds-with-App-revealup/
https://www.perl.com/article/134/2014/11/13/Advanced-slideshow-maneuvers/
