//------------------------------------------------------------------------------
//  Copyright (c) 2009-2013 the original author or authors. All Rights Reserved. 
// 
//  NOTICE: You are permitted to use, modify, and distribute this file 
//  in accordance with the terms of the license agreement accompanying it. 
//------------------------------------------------------------------------------

package robotlegs.bender.extensions.eventCommandMap.impl
{
	import flash.events.Event;
	import flash.events.IEventDispatcher;
	import org.swiftsuspenders.Injector;
	import robotlegs.bender.extensions.commandCenter.api.ICommandExecutor;
	import robotlegs.bender.extensions.commandCenter.api.ICommandMapping;
	import robotlegs.bender.extensions.commandCenter.api.ICommandMappingList;
	import robotlegs.bender.extensions.commandCenter.api.ICommandTrigger;
	import robotlegs.bender.extensions.commandCenter.impl.CommandExecutor;
	import robotlegs.bender.extensions.commandCenter.impl.CommandMappingList;
	import robotlegs.bender.framework.api.ILogger;

	/**
	 * @private
	 */
	public class EventCommandTrigger implements ICommandTrigger
	{
		/*============================================================================*/
		/* Private Properties                                                         */
		/*============================================================================*/

		private var _dispatcher:IEventDispatcher;

		private var _type:String;

		private var _eventClass:Class;

		private var _injector:Injector;

		private var _mappings:ICommandMappingList;

		/*============================================================================*/
		/* Constructor                                                                */
		/*============================================================================*/

		/**
		 * @private
		 */
		public function EventCommandTrigger(
			injector:Injector,
			dispatcher:IEventDispatcher,
			type:String,
			eventClass:Class = null,
			logger:ILogger = null)
		{
			_injector = injector.createChildInjector();
			_dispatcher = dispatcher;
			_type = type;
			_eventClass = eventClass;
			_mappings = new CommandMappingList(this, logger).withSortFunction(compareFunction);
		}

		/*============================================================================*/
		/* Public Functions                                                           */
		/*============================================================================*/

		public function createMapper():EventCommandMapper
		{
			return new EventCommandMapper(_mappings);
		}

		public function activate():void
		{
			_dispatcher.addEventListener(_type, eventHandler);
		}

		public function deactivate():void
		{
			_dispatcher.removeEventListener(_type, eventHandler);
		}

		public function toString():String
		{
			return _eventClass + " with selector '" + _type + "'";
		}

		/*============================================================================*/
		/* Private Functions                                                          */
		/*============================================================================*/

		private function eventHandler(event:Event):void
		{
			const eventConstructor:Class = event["constructor"] as Class;
			if (_eventClass && eventConstructor != _eventClass)
			{
				return;
			}
			const executor:ICommandExecutor = new CommandExecutor(_mappings, _injector)
				.withPayloadMapper(function(mapping:ICommandMapping):void
				{
					_injector.map(Event).toValue(event);
					if (eventConstructor != Event)
						_injector.map(_eventClass || eventConstructor).toValue(event);
				})
				.withPayloadUnmapper(function(mapping:ICommandMapping):void
				{
					_injector.unmap(Event);
					if (eventConstructor != Event)
						_injector.unmap(_eventClass || eventConstructor);
				});
			executor.execute();
		}

		private function compareFunction(a:EventCommandMapping, b:EventCommandMapping):Number
		{
			return b.priority - a.priority;
		}
	}
}

