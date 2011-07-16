package org.robotlegs.base
{
	import org.osflash.signals.ISignal;
	import org.robotlegs.core.IInjector;
	import org.robotlegs.core.ISignalCommandMap;

	import flash.utils.Dictionary;
	import flash.utils.describeType;

	public class SignalCommandMap implements ISignalCommandMap
    {
        protected var injector:IInjector;
        protected var signalMap:Dictionary;
        protected var signalClassMap:Dictionary;
        protected var verifiedCommandClasses:Dictionary;
        protected var detainedCommands:Dictionary;

        public function SignalCommandMap(injector:IInjector)
        {
            this.injector = injector;
            signalMap = new Dictionary( false );
            signalClassMap = new Dictionary( false );
            verifiedCommandClasses = new Dictionary( false );
            detainedCommands = new Dictionary( false );
        }

        public function mapSignal(signal:ISignal, commandClass:Class, oneShot:Boolean = false, named:String = ""):void
        {
	    //@see https://github.com/joelhooks/signals-extensions-CommandSignal/issues/2#issuecomment-984481
            if(named != "" && signal.valueClasses.length > 1)
                //FIXME hardcode
                throw new ContextError("use named param in mapSignal with a Signal class that has more than one valueClasses");
            verifyCommandClass( commandClass );
            if ( hasSignalCommand( signal, commandClass ) )
                return;
            var signalCommandMap:Dictionary = signalMap[signal] ||= new Dictionary( false );
            var callback:Function = function(a:* = null, b:* = null, c:* = null, d:* = null, e:* = null, f:* = null, g:* = null):void
            {
                routeSignalToCommand(signal, arguments, commandClass, oneShot, named);
            };

            signalCommandMap[commandClass] = callback;
            signal.add( callback );
        }

        public function mapSignalClass(signalClass:Class, commandClass:Class, oneShot:Boolean = false, named:String = ""):ISignal
        {
            var signal:ISignal = getSignalClassInstance( signalClass );
            mapSignal(signal, commandClass, oneShot, named);
            return signal;
        }

        protected function getSignalClassInstance(signalClass:Class):ISignal
        {
            return ISignal(signalClassMap[signalClass]) || createSignalClassInstance(signalClass);
        }

        private function createSignalClassInstance(signalClass:Class):ISignal
        {
            var injectorForSignalInstance:IInjector = injector;
            var signal:ISignal;
            if(injector.hasMapping(IInjector))
                injectorForSignalInstance = injector.getInstance(IInjector);
            signal = injectorForSignalInstance.instantiate( signalClass );
            injectorForSignalInstance.mapValue( signalClass, signal );
            signalClassMap[signalClass] = signal;
            return signal;
        }

        public function hasSignalCommand(signal:ISignal, commandClass:Class):Boolean
        {
            var callbacksByCommandClass:Dictionary = signalMap[signal];
            if ( callbacksByCommandClass == null ) return false;
            var callback:Function = callbacksByCommandClass[commandClass];
            return callback != null;
        }

        public function unmapSignal(signal:ISignal, commandClass:Class):void
        {
            var callbacksByCommandClass:Dictionary = signalMap[signal];
            if ( callbacksByCommandClass == null ) return;
            var callback:Function = callbacksByCommandClass[commandClass];
            if ( callback == null ) return;
            signal.remove( callback );
            delete callbacksByCommandClass[commandClass];
        }
		
        public function unmapSignalClass(signalClass:Class, commandClass:Class):void
        {
			unmapSignal(getSignalClassInstance(signalClass), commandClass);
		}

        protected function routeSignalToCommand(signal:ISignal, valueObjects:Array, commandClass:Class, oneshot:Boolean, named:String = ""):void
        {
            mapSignalValues(signal.valueClasses, valueObjects, named);
            createCommandInstance( commandClass).execute();
            unmapSignalValues(signal.valueClasses, valueObjects, named);
            if ( oneshot )
                unmapSignal( signal, commandClass );
        }

        protected function createCommandInstance(commandClass:Class):Object {
            return injector.instantiate(commandClass);
        }

        protected function mapSignalValues(valueClasses:Array, valueObjects:Array, named:String = ""):void {
            for (var i:uint = 0; i < valueClasses.length; i++) {
                injector.mapValue(valueClasses[i], valueObjects[i], named);
            }
        }

        protected function unmapSignalValues(valueClasses:Array, valueObjects:Array, named:String = ""):void {
            for (var i:uint = 0; i < valueClasses.length; i++) {
                injector.unmap(valueClasses[i], named);
            }
        }

        protected function verifyCommandClass(commandClass:Class):void
        {
            if ( verifiedCommandClasses[commandClass] ) return;
			if (describeType( commandClass ).factory.method.(@name == "execute").length() != 1)
			{
				throw new ContextError( ContextError.E_COMMANDMAP_NOIMPL + ' - ' + commandClass );
			}
			verifiedCommandClasses[commandClass] = true;
        }
		
        public function detain(command:Object):void
        {
            detainedCommands[command] = true;
        }
        public function release(command:Object):void
        {
            if (detainedCommands[command])
                delete detainedCommands[command];
        }
    }
}
