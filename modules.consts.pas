unit modules.consts;

interface

resourcestring
  sPortInUse = '- Error: Port %s already in use';
  sPortSet = '- Port set to %s';
  sServerRunning = '- The Server is already running';
  sStartingServer = '- Starting HTTP Server on port %d';
  sStoppingServer = '- Stopping Server';
  sServerStopped = '- Server Stopped';
  sServerNotRunning = '- The Server is not running';
  sInvalidCommand = '- Error: Invalid Command';
  sIndyVersion = '- Indy Version: ';
  sActive = '- Active: ';
  sPort = '- Port: ';
  sSessionID = '- Session ID CookieName: ';
  sCommands = 'Enter a Command: ' + slineBreak +
    '   - "start" to start the server'+ slineBreak +
    '   - "stop" to stop the server'+ slineBreak +
    '   - "set port" to change the default port'+ slineBreak +
    '   - "status" for Server status'+ slineBreak +
    '   - "help" to show commands'+ slineBreak +
    '   - "exit" to close the application';

const
  cArrow = '->';
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

implementation

end.
