package org.robotlegs.v2.viewmanager 
{
	import flash.display.DisplayObjectContainer;
	import flash.display.DisplayObject;
	import flash.utils.Dictionary;
	
	public class ContainerTreeCreeper implements IContainerTreeCreeper 
	{
		protected const _bindingsByContainer:Dictionary = new Dictionary();
		protected var _rootBindings:Vector.<IContainerBinding>;
		
		public function findParentBindingFor(targetObject:DisplayObject):IContainerBinding
		{         
			var checkParent:DisplayObjectContainer = targetObject.parent;
        	while(checkParent)
			{                                              
				if(_bindingsByContainer[checkParent])
				{
					return _bindingsByContainer[checkParent];
				}
				checkParent = checkParent.parent;
			}
			return null;
		}
		
		public function getContainerBindingFor(container:DisplayObjectContainer):IContainerBinding
		{
        	return _bindingsByContainer[container];
		}

		public function includeContainer(container:DisplayObjectContainer):IContainerBinding
		{            
			var binding:IContainerBinding = _bindingsByContainer[container] ||= createBindingFor(container);
 			buildRootBindings(binding);
			return binding;
		}   

		public function excludeContainer(container:DisplayObjectContainer):IContainerBinding
		{                          
			if(!_bindingsByContainer[container])
				return null;
			var binding:IContainerBinding = removeBindingFor(container);
 			buildRootBindings(binding);
			return binding;
		}
		
		public function get rootContainerBindings():Vector.<IContainerBinding>
		{          
			return _rootBindings;
		} 
		
		protected function buildRootBindings(includedOrExcludedBinding:IContainerBinding):void
		{
			if(includedOrExcludedBinding.parent)
				return;

			_rootBindings = new Vector.<IContainerBinding>();
			for each (var binding:IContainerBinding in _bindingsByContainer)
			{
				if(binding.parent == null)
				{
					_rootBindings.push(binding)
				}
			}
		}   

		protected function createBindingFor(container:DisplayObjectContainer):IContainerBinding
		{
			const binding:IContainerBinding = new ContainerBinding(container, removeBinding);
			binding.parent = findParentBindingFor(container);
			addToChildBindings(binding, container);
			return binding;
		}
		
		protected function removeBindingFor(container:DisplayObjectContainer):IContainerBinding
		{
			const binding:IContainerBinding = _bindingsByContainer[container];
		    delete _bindingsByContainer[container];
			removeFromChildBindings(binding);
        	return binding;
		}
		
		protected function addToChildBindings(binding:IContainerBinding, container:DisplayObjectContainer):void
		{        
			var childView:Object;
			for (childView in _bindingsByContainer)
			{
				if(container.contains(childView as DisplayObject) && 
					(   (! _bindingsByContainer[childView].parent) ||
						(! container.contains(_bindingsByContainer[childView].parent.container))	) 	)
				{
					_bindingsByContainer[childView].parent = binding;
				}
			}
		}
		
		protected function removeFromChildBindings(binding:IContainerBinding):void
		{                         
			var childBinding:IContainerBinding;
			for each (childBinding in _bindingsByContainer)
			{
				if(childBinding.parent == binding)
				{
					childBinding.parent = binding.parent;
				}
			}
		}
		
		protected function removeBinding(binding:IContainerBinding):void
		{
			excludeContainer(binding.container);
		}
	}
}