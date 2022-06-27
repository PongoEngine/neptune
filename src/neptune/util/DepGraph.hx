package neptune.util;

import haxe.macro.Expr;

using Lambda;

typedef Options = {
	?circular:Bool
}

class DepGraph {
	/**
	 * Helper for creating a Topological Sort using Depth-First-Search on a set of edges.
	 *
	 * Detects cycles and throws an Error if one is detected (unless the "circular"
	 * parameter is "true" in which case it ignores them).
	 *
	 * @param edges The set of edges to DFS through
	 * @param leavesOnly Whether to only return "leaf" nodes (ones who have no edges)
	 * @param result An array in which the results will be populated
	 * @param circular A boolean to allow circular dependencies
	 */
	public static function createDFS(edges:Map<Node, DependencyNode>, leavesOnly:Bool, result:Array<Node>, circular:Bool) {
		var visited = new Map<Node, Bool>();
		return function(start:Node) {
			if (visited[start]) {
				return;
			}
			var inCurrentPath = new Map<Node, Bool>();
			var currentPath = [];
			var todo = []; // used as a stack
			todo.push({node: start, processed: false});
			while (todo.length > 0) {
				var current = todo[todo.length - 1]; // peek at the todo stack
				var processed = current.processed;
				var node = current.node;
				if (!processed) {
					// Haven't visited edges yet (visiting phase)
					if (visited[node]) {
						todo.pop();
						continue;
					} else if (inCurrentPath[node]) {
						// It's not a DAG
						if (circular) {
							todo.pop();
							// If we're tolerating cycles, don't revisit the node
							continue;
						}
						currentPath.push(node);
						throw 'DepGraphCycleError(${currentPath})';
					}

					inCurrentPath[node] = true;
					currentPath.push(node);
					var nodeEdges = edges[node];
					// (push edges onto the todo stack in reverse order to be order-compatible with the old DFS implementation)
					var i = nodeEdges.length - 1;
					while (i >= 0) {
						todo.push({node: nodeEdges[i], processed: false});
						i--;
					}
					current.processed = true;
				} else {
					// Have visited edges (stack unrolling phase)
					todo.pop();
					currentPath.pop();
					inCurrentPath[node] = false;
					visited[node] = true;
					if (!leavesOnly || edges[node].length == 0) {
						result.push(node);
					}
				}
			}
		};
	}

	/**
	 * Creates an instance of DepGraph with optional Options.
	 */
	public function new(?opts:Options) {
		this._nodes = new Map();
		this._outgoingEdges = new Map();
		this._incomingEdges = new Map();
		this._circular = opts != null ? opts.circular : false;
		this._length = 0;
	}

	/**
	 * The number of nodes in the graph.
	 */
	public function size():Int {
		return this._length;
	}

	/**
	 * Add a node in the graph with optional data. If data is not given, name will be used as data.
	 * @param {string} name
	 * @param data
	 */
	public function addNode(node:Node, ?data:Node):Node {
		if (!this.hasNode(node)) {
			// Checking the arguments length allows the user to add a node with undefined data
			if (data != null) {
				this._nodes[node] = data;
			} else {
				this._nodes[node] = node;
			}
			this._outgoingEdges[node] = [];
			this._incomingEdges[node] = [];
			this._length++;
		}
		return node;
	}

	/**
	 * Remove a node from the graph.
	 * @param {string} name
	 */
	public function removeNode(node:Node):Void {
		if (this.hasNode(node)) {
			this._nodes.remove(node);
			this._outgoingEdges.remove(node);
			this._incomingEdges.remove(node);

			for (edgeList in [this._outgoingEdges, this._outgoingEdges]) {
				for (key in edgeList.keys()) {
					var idx = edgeList[key].indexOf(node);
					if (idx >= 0) {
						edgeList[key].splice(idx, 1);
					}
				}
			}
			this._length--;
		}
	}

	/**
	 * Check if a node exists in the graph.
	 * @param {string} name
	 */
	public function hasNode(node:Node):Bool {
		return this._nodes.exists(node);
	}

	/**
	 * Get the data associated with a node (will throw an Error if the node does not exist).
	 * @param {string} name
	 */
	public function getNodeData(node:Node):Node {
		if (this.hasNode(node)) {
			return this._nodes[node];
		} else {
			throw "Node does not exist: " + node;
		}
	}

	/**
	 * Set the data for an existing node (will throw an Error if the node does not exist).
	 * @param {string} name
	 * @param data
	 */
	public function setNodeData(node:Node, ?data:Node):Void {
		if (this.hasNode(node)) {
			this._nodes[node] = data;
		} else {
			throw "Node does not exist: " + node;
		}
	}

	/**
	 * Add a dependency between two nodes (will throw an Error if one of the nodes does not exist).
	 * @param {string} from
	 * @param {string} to
	 */
	public function addDependency(from:Node, to:Node):Bool {
		if (!this.hasNode(from)) {
			throw "Node does not exist: " + from;
		}
		if (!this.hasNode(to)) {
			throw "Node does not exist: " + to;
		}
		if (this._outgoingEdges[from].indexOf(to) == -1) {
			this._outgoingEdges[from].push(to);
		}
		if (this._incomingEdges[to].indexOf(from) == -1) {
			this._incomingEdges[to].push(from);
		}
		return true;
	}

	/**
	 * Remove a dependency between two nodes.
	 * @param {string} from
	 * @param {string} to
	 */
	public function removeDependency(from:Node, to:Node):Void {
		var idx;
		if (this.hasNode(from)) {
			idx = this._outgoingEdges[from].indexOf(to);
			if (idx >= 0) {
				this._outgoingEdges[from].splice(idx, 1);
			}
		}

		if (this.hasNode(to)) {
			idx = this._incomingEdges[to].indexOf(from);
			if (idx >= 0) {
				this._incomingEdges[to].splice(idx, 1);
			}
		}
	}

	/**
	 * Return a clone of the dependency graph (If any custom data is attached
	 * to the nodes, it will only be shallow copied).
	 */
	public function clone():DepGraph {
		var source = this;
		var result = new DepGraph();
		for (n in source._nodes.keys()) {
			result._nodes[n] = source._nodes[n];
			result._outgoingEdges[n] = source._outgoingEdges[n].slice(0);
			result._incomingEdges[n] = source._incomingEdges[n].slice(0);
		};
		return result;
	}

	/**
	 * Get an array containing the direct dependency nodes of the specified node.
	 * @param name
	 */
	public function directDependenciesOf(node:Node):Array<Node> {
		if (this.hasNode(node)) {
			return this._outgoingEdges[node].slice(0);
		} else {
			throw "Node does not exist: " + node;
		}
	}

	/**
	 * Get an array containing the nodes that directly depend on the specified node.
	 * @param name
	 */
	public function directDependentsOf(node:Node):Array<Node> {
		if (this.hasNode(node)) {
			return this._incomingEdges[node].slice(0);
		} else {
			throw "Node does not exist: " + node;
		}
	}

	/**
	 * Get an array containing the nodes that the specified node depends on (transitively). If leavesOnly is true, only nodes that do not depend on any other nodes will be returned in the array.
	 * @param {string} name
	 * @param {boolean} leavesOnly
	 */
	public function dependenciesOf(node:Node, ?leavesOnly:Bool):Array<Node> {
		if (this.hasNode(node)) {
			var result = [];
			var DFS = createDFS(this._outgoingEdges, leavesOnly, result, this._circular);
			DFS(node);
			var idx = result.indexOf(node);
			if (idx >= 0) {
				result.splice(idx, 1);
			}
			return result;
		} else {
			throw "Node does not exist: " + node;
		}
	}

	/**
	 * Get an array containing the nodes that depend on the specified node (transitively). If leavesOnly is true, only nodes that do not have any dependants will be returned in the array.
	 * @param {string} name
	 * @param {boolean} leavesOnly
	 */
	public function dependentsOf(node:Node, ?leavesOnly:Bool):Array<Node> {
		if (this.hasNode(node)) {
			var result = [];
			var DFS = createDFS(this._incomingEdges, leavesOnly, result, this._circular);
			DFS(node);
			var idx = result.indexOf(node);
			if (idx >= 0) {
				result.splice(idx, 1);
			}
			return result;
		} else {
			throw "Node does not exist: " + node;
		}
	}

	/**
	 * Get an array of nodes that have no dependants (i.e. nothing depends on them).
	 */
	public function entryNodes():Array<Node> {
		var arra:Array<Node> = [];
		for (node in this._nodes.keys()) {
			if (this._incomingEdges[node].length == 0) {
				arra.push(node);
			}
		}
		return arra;
	}

	/**
	 * Construct the overall processing order for the dependency graph. If leavesOnly is true, only nodes that do not depend on any other nodes will be returned.
	 * @param {boolean} leavesOnly
	 */
	public function overallOrder(?leavesOnly:Bool):Array<Node> {
		var self = this;
		var result:Array<Node> = [];
		// var keys = Object.keys(this._nodes);
		var keys:Array<Node> = [];
		for (key in this._nodes.keys()) {
			keys.push(key);
		}
		if (keys.length == 0) {
			return result; // Empty graph
		} else {
			if (!this._circular) {
				// Look for cycles - we run the DFS starting at all the nodes in case there
				// are several disconnected subgraphs inside this dependency graph.
				var CycleDFS = createDFS(this._outgoingEdges, false, [], this._circular);
				keys.foreach(function(n) {
					CycleDFS(n);
					return true;
				});
			}

			var DFS = createDFS(this._outgoingEdges, leavesOnly, result, this._circular);
			// Find all potential starting points (nodes with nothing depending on them) an
			// run a DFS starting at these points to get the order
			keys.filter(function(node) {
				return self._incomingEdges[node].length == 0;
			}).foreach(function(n) {
				DFS(n);
				return true;
			});

			// If we're allowing cycles - we need to run the DFS against any remaining
			// nodes that did not end up in the initial result (as they are part of a
			// subgraph that does not have a clear starting point)
			if (this._circular) {
				keys.filter(function(node) {
					return result.indexOf(node) == -1;
				}).foreach(function(n) {
					DFS(n);
					return true;
				});
			}

			return result;
		}
	}

	private var _nodes:Map<Node, Node>; // Node -> Node/Data (treated like a Set)
	private var _outgoingEdges:Map<Node, DependencyNode>; // Node -> [Dependency Node]
	private var _incomingEdges:Map<Node, DependencyNode>; // Node -> [Dependant Node]
	private var _circular:Bool; // Allows circular deps
	private var _length:Int;
}

typedef Node = Expr;
typedef DependencyNode = Array<Expr>;
