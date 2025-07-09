unit modules.consts;

interface

resourcestring
  sStartingServer = '🟢 Starting HTTP Server on port %d';
  sPortInUse = '❌ Error: Port %s already in use';
  sPortSet = '🌐Port set to %s';
  sServerRunning = '✅ The Server is already running';

  sStoppingServer = '🛑 Stopping Server';
  sServerStopped = '🔴 Server Stopped';
  sServerNotRunning = '⚠ The Server is not running';
  sInvalidCommand = '❌ Error: Invalid Command';
  sIndyVersion = 'ℹ ️Indy Version: ';
  sActive = '✅ Active: ';
  sPort = '🌐 Port: ';
  sSessionID = '🍪 Session ID CookieName: ';
  sCommands = '''
      Enter a Command:

       🔸 "start" to start the server
       🔸 "stop" to stop the server
       🔸 "set port" to change the default port
       🔸 "status" for Server status
       🔸 "help" to show commands
       🔸 "exit" to close the application
      ''';
  sWelcomeText = '''
  ########:::::'###::::'########:::::'########:'########:::::'###::::'##::: ##::'######::'##::::::::::'###::::'########:'########:
  ##.... ##:::'## ##::: ##.... ##::::... ##..:: ##.... ##:::'## ##::: ###:: ##:'##... ##: ##:::::::::'## ##:::... ##..:: ##.....::
  ##:::: ##::'##:. ##:: ##:::: ##::::::: ##:::: ##:::: ##::'##:. ##:: ####: ##: ##:::..:: ##::::::::'##:. ##::::: ##:::: ##:::::::
  ########::'##:::. ##: ##:::: ##::::::: ##:::: ########::'##:::. ##: ## ## ##:. ######:: ##:::::::'##:::. ##:::: ##:::: ######:::
  ##.. ##::: #########: ##:::: ##::::::: ##:::: ##.. ##::: #########: ##. ####::..... ##: ##::::::: #########:::: ##:::: ##...::::
  ##::. ##:: ##.... ##: ##:::: ##::::::: ##:::: ##::. ##:: ##.... ##: ##:. ###:'##::: ##: ##::::::: ##.... ##:::: ##:::: ##:::::::
  ##:::. ##: ##:::: ##: ########:::::::: ##:::: ##:::. ##: ##:::: ##: ##::. ##:. ######:: ########: ##:::: ##:::: ##:::: ########:
  .:::::..::..:::::..::........:::::::::..:::::..:::::..::..:::::..::..::::..:::......:::........::..:::::..:::::..:::::........::

  👋 Welcome!

  ''';

  sServerReady = 'The server is ready. Access it via http://localhost:%d in your web browser';

const
  cArrow = #10 + '➡  ';
  cCommandStart = 'start';
  cCommandStop = 'stop';
  cCommandStatus = 'status';
  cCommandHelp = 'help';
  cCommandSetPort = 'set port';
  cCommandExit = 'exit';

  cLangNormal = '''
	<div class="textcontainer" id="textboxes">
			<textarea id="originalcontent" name="ogcontent" maxlength="5000" hx-post="/translatetext" hx-trigger="delay:500ms changed" hx-target="#translatedcontent" hx-swap="innerHTML">%s</textarea>
      &nbsp;
	    <textarea id="translatedcontent" name="transcontent" placeholder="Translation">%s</textarea>
	</div>
''';

  cLangSwapped = '''
	<div class="textcontainer" id="textboxes">
	    <textarea id="translatedcontent" name="transcontent" placeholder="Translation">%s</textarea>
			&nbsp;
			<textarea id="originalcontent" name="ogcontent" maxlength="5000" hx-post="/translatetext" hx-trigger="delay:500ms changed" hx-target="#translatedcontent" hx-swap="innerHTML">%s</textarea>
	</div>
''';

  cLangBlockPart1 = '''
			<div id="langblock" name="langblock">
			  <ul class="navbar-nav me-auto mb-2 mb-lg-0">
					<li class="nav-item">
					  <a id="detected" name="detected" class="nav-link active text-primary" aria-current="page" href="#">
''';

  cDetectedDiv = '<div id="detectedlang" name="detectedlang">';
  cLangBlockPart2 = '''
					</li>
					<li class="nav-item dropdown">
					  <a class="nav-link dropdown-toggle" href="#" role="button" data-bs-toggle="dropdown" aria-expanded="false">
						&nbsp;
					  </a>
					  <ul class="dropdown-menu">
''';


implementation

end.
