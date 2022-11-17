package Y::Tools;
use base 'ToolSet'; 

#-T
BEGIN{ use Taint::Runtime 'enable'; Taint::Runtime::taint_env }

#-Mstrict
ToolSet->set_strict(1);

#-w, there doesn't seem to be a way to invoke -W at run time
ToolSet->set_warnings(1);

ToolSet->export(
		#But we can still tighten things up...
		'warnings' => [FATAL=>'all'],
		
		#...and reduce him to tears,
		'criticism'=>'brutal',
		
		#with a lovely poem.
		'Coy' => undef,
		
		#Finally, let's go one 'better' than strict
		'Acme::use::strict::with::pride' => undef,
	       );

"I perform over fifty mega-checks per second!";
