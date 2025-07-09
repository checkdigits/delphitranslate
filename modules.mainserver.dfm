object WebModule1: TWebModule1
  OnCreate = WebModuleCreate
  OnDestroy = WebModuleDestroy
  Actions = <
    item
      MethodType = mtGet
      Name = 'TranslateTextAction'
      PathInfo = '/translatetext'
      ProducerContent = WebStencilsProcessor1
      OnAction = WebModule1TranslateTextActionAction
    end
    item
      MethodType = mtGet
      Name = 'SwapAction'
      PathInfo = '/swap'
      ProducerContent = WebStencilsProcessor1
      OnAction = WebModule1SwapActionAction
    end
    item
      MethodType = mtGet
      Name = 'MenuAction'
      PathInfo = '/menu'
      ProducerContent = WebStencilsProcessor1
    end
    item
      Name = 'SetNewLangAction'
      PathInfo = '/setnewlang'
      ProducerContent = WebStencilsProcessor1
      OnAction = WebModule1SetNewLangActionAction
    end>
  Height = 230
  Width = 415
  object WebStencilsEngine: TWebStencilsEngine
    Dispatcher = WebFileDispatcher
    PathTemplates = <
      item
        Template = '/'
        Redirect = 'delphitranslate.html'
      end>
    RootDirectory = '../../html/'
    OnValue = WebStencilsEngineValue
    OnFile = WebStencilsEngineFile
    OnPathInit = WebStencilsEnginePathInit
    Left = 80
    Top = 40
  end
  object WebFileDispatcher: TWebFileDispatcher
    WebFileExtensions = <
      item
        MimeType = 'text/css'
        Extensions = 'css'
      end
      item
        MimeType = 'text/html'
        Extensions = 'html;htm'
      end
      item
        MimeType = 'application/javascript'
        Extensions = 'js'
      end
      item
        MimeType = 'image/jpeg'
        Extensions = 'jpeg;jpg'
      end
      item
        MimeType = 'image/png'
        Extensions = 'png'
      end
      item
        MimeType = 'image/svg+xml'
        Extensions = 'svg;svgz'
      end
      item
        MimeType = 'image/x-icon'
        Extensions = 'ico'
      end>
    WebDirectories = <
      item
        DirectoryAction = dirInclude
        DirectoryMask = '*'
      end
      item
        DirectoryAction = dirExclude
        DirectoryMask = '\templates\*'
      end>
    RootDirectory = '../../html/'
    VirtualPath = '/'
    Left = 216
    Top = 48
  end
  object WebStencilsProcessor1: TWebStencilsProcessor
    Engine = WebStencilsEngine
    Left = 88
    Top = 120
  end
end
