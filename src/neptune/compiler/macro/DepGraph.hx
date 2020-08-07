package neptune.compiler.macro;

/*
* Copyright (c) 2020 Jeremy Meltingtallow
*
* Permission is hereby granted, free of charge, to any person obtaining a copy of
* this software and associated documentation files (the "Software"), to deal in
* the Software without restriction, including without limitation the rights to use,
* copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the
* Software, and to permit persons to whom the Software is furnished to do so,
* subject to the following conditions:
*
* The above copyright notice and this permission notice shall be included in all
* copies or substantial portions of the Software.
*
* THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
* IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS
* FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR
* COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN
* AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH
* THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
*/

//built using https://github.com/jriecken/dependency-graph

#if macro

using Lambda;

typedef Options = {
    circular: Bool
}

class DepGraph<T>
{
    public var nodes : Map<String, T>;
    public var outgoingEdges : Map<String, Array<String>>;
    public var incomingEdges : Map<String, Array<String>>;
    public var circular : Bool;

    private var _length :Int;

    /**
     * Creates an instance of DepGraph with optional Options.
     */
    public function new(opts: Options) : Void
    {
        this.nodes = new Map<String, T>(); // Node -> Node/Data (treated like a Set)
        this.outgoingEdges = new Map<String, Array<String>>(); // Node -> [Dependency Node]
        this.incomingEdges = new Map<String, Array<String>>(); // Node -> [Dependant Node]
        this.circular = opts.circular; // Allows circular deps
        _length = 0;
    }

    /**
     * The number of nodes in the graph.
     */
    public function size(): Int
    {
        return _length;
    }

    /**
     * Add a node in the graph with optional data. If data is not given, name will be used as data.
     * @param {string} name
     * @param data
     */
    public function addNode(node: String, ?data: T): Void
    {
        if (!this.hasNode(node)) {
            // Checking the arguments length allows the user to add a node with undefined data
            this.nodes.set(node, data);
            this.outgoingEdges[node] = [];
            this.incomingEdges[node] = [];
            _length++;
        }
    }

    /**
     * Remove a node from the graph.
     * @param {string} name
     */
    public function removeNode(name: String): Void
    {
        if (this.hasNode(name)) {
            this.nodes.remove(name);
            this.incomingEdges.remove(name);
            this.outgoingEdges.remove(name);

            for(edge in this.incomingEdges) {
                for(item in edge) {
                    var idx = edge.indexOf(name);
                    if(idx >= 0) {
                        edge.splice(idx, 1);
                    }
                }
            }

            for(edge in this.outgoingEdges) {
                for(item in edge) {
                    var idx = edge.indexOf(name);
                    if(idx >= 0) {
                        edge.splice(idx, 1);
                    }
                }
            }

            _length--;
        }
    }

    /**
     * Check if a node exists in the graph.
     * @param {string} name
     */
    public function hasNode(name: String): Bool
    {
        return this.nodes.exists(name);
    }

    /**
     * Get the data associated with a node (will throw an Error if the node does not exist).
     * @param {string} name
     */
    public function getNodeData(name: String): T
    {
        if (this.hasNode(name)) {
            return this.nodes.get(name);
        } else {
            throw "Node does not exist: " + name;
        }
    }

    /**
     * Set the data for an existing node (will throw an Error if the node does not exist).
     * @param {string} name
     * @param data
     */
    public function setNodeData(name: String, data: T): Void
    {
        if (this.hasNode(name)) {
            this.nodes.set(name, data);
        } else {
            throw "Node does not exist: " + name;
        }
    }

    /**
     * Add a dependency between two nodes (will throw an Error if one of the nodes does not exist).
     * @param {string} from
     * @param {string} to
     */
    public function addDependency(from: String, to: String): Void
    {
        if (!this.hasNode(from)) {
            throw "Node does not exist: " + from;
        }
        if (!this.hasNode(to)) {
            throw "Node does not exist: " + to;
        }
        if (this.outgoingEdges.get(from).indexOf(to) == -1) {
            this.outgoingEdges.get(from).push(to);
        }
        if (this.incomingEdges.get(to).indexOf(from) == -1) {
            this.incomingEdges.get(to).push(from);
        }
    }

    /**
     * Remove a dependency between two nodes.
     * @param {string} from
     * @param {string} to
     */
    public function removeDependency(from: String, to: String): Void
    {
        var idx = 0;
        if (this.hasNode(from)) {
            idx = this.outgoingEdges.get(from).indexOf(to);
            if (idx >= 0) {
                this.outgoingEdges.get(from).splice(idx, 1);
            }
        }

        if (this.hasNode(to)) {
            idx = this.incomingEdges.get(to).indexOf(from);
            if (idx >= 0) {
                this.incomingEdges.get(to).splice(idx, 1);
            }
        }
    }

    /**
     * Return a clone of the dependency graph (If any custom data is attached
     * to the nodes, it will only be shallow copied).
     */
    public function clone(): DepGraph<T>
    {
        var result = new DepGraph({circular: this.circular});
        
        var keys = this.nodes.keys();
        for(key in keys) {
            result.nodes.set(key, this.nodes.get(key));
            result.incomingEdges.set(key, this.incomingEdges.get(key).slice(0));
            result.outgoingEdges.set(key, this.outgoingEdges.get(key).slice(0));
        }

        return result;
    }

    /**
     * Get an array containing the nodes that the specified node depends on (transitively). If leavesOnly is true, only nodes that do not depend on any other nodes will be returned in the array.
     * @param {string} name
     * @param {boolean} leavesOnly
     */
    public function dependenciesOf(name: String, leavesOnly: Bool = false): Array<String>
    {
        if (this.hasNode(name)) {
            var result = [];

            var DFS = createDFS(
                this.outgoingEdges,
                leavesOnly,
                result,
                this.circular
            );

            DFS(name);

            var idx = result.indexOf(name);
            if (idx >= 0) {
                result.splice(idx, 1);
            }

            return result;
        } 
        else {
            throw "Node does not exist: " + name;
        }
    }

    /**
     * Get an array containing the nodes that depend on the specified node (transitively). If leavesOnly is true, only nodes that do not have any dependants will be returned in the array.
     * @param {string} name
     * @param {boolean} leavesOnly
     */
    public function dependantsOf(name: String, leavesOnly: Bool = false): Array<String>
    {
        if (this.hasNode(name)) {
            var result = [];

            var DFS = createDFS(
                this.incomingEdges,
                leavesOnly,
                result,
                this.circular
            );

            DFS(name);

            var idx = result.indexOf(name);
            if (idx >= 0) {
                result.splice(idx, 1);
            }
            return result;
        } 
        else {
            throw "Node does not exist: " + name;
        }
    }

    /**
     * Construct the overall processing order for the dependency graph. If leavesOnly is true, only nodes that do not depend on any other nodes will be returned.
     * @param {boolean} leavesOnly
     */
    public function overallOrder(leavesOnly: Bool = false): Array<String>
    {
        var self = this;
        var result = [];
        var keys = [];
        for(key in this.nodes.keys()) {
            keys.push(key);
        }

        if (keys.length == 0) {
            return result; // Empty graph
        } 
        else {
            if (!this.circular) {
                // Look for cycles - we run the DFS starting at all the nodes in case there
                // are several disconnected subgraphs inside this dependency graph.
                var CycleDFS = createDFS(this.outgoingEdges, false, [], this.circular);
                keys.foreach(key -> {
                    CycleDFS(key);
                    return true;
                });
            }

            var DFS = createDFS(
                this.outgoingEdges,
                leavesOnly,
                result,
                this.circular
            );

            // Find all potential starting points (nodes with nothing depending on them) an
            // run a DFS starting at these points to get the order
            keys
                .filter(function(node) {
                    return self.incomingEdges[node].length == 0;
                })
                .foreach(n -> {
                    DFS(n);
                    return true;
                });

            // If we're allowing cycles - we need to run the DFS against any remaining
            // nodes that did not end up in the initial result (as they are part of a
            // subgraph that does not have a clear starting point)
            if (this.circular) {
                keys
                    .filter(function(node) {
                        return result.indexOf(node) == -1;
                    })
                    .foreach(n -> {
                        DFS(n);
                        return true;
                    });
            }

            return result;
        }
    }

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
    public static function createDFS(edges :Map<String, Array<String>>, leavesOnly :Bool, result :Array<String>, circular :Bool) : String -> Void
    {
        var visited = new Map<String, Bool>();

        return function(start) {

            if (visited.get(start)) {
                return;
            }

            var inCurrentPath = new Map<String, Bool>();
            var currentPath :Array<String> = [];
            var todo :Array<{node :Dynamic, processed :Bool}> = []; // used as a stack
            todo.push({ node: start, processed: false });

            while (todo.length > 0) {
                var current = todo[todo.length - 1]; // peek at the todo stack
                var processed = current.processed;
                var node = current.node;
                if (!processed) {
                    // Haven't visited edges yet (visiting phase)
                    if (visited[node]) {
                        todo.pop();
                        continue;
                    } 
                    else if (inCurrentPath[node]) {
                        // It's not a DAG
                        if (circular) {
                            todo.pop();
                            // If we're tolerating cycles, don't revisit the node
                            continue;
                        }
                        currentPath.push(node);
                        // throw new DepGraphCycleError(currentPath);
                        throw 'DepGraphCycleError ${currentPath}';
                    }

                    inCurrentPath[node] = true;
                    currentPath.push(node);
                    var nodeEdges = edges[node];

                    // (push edges onto the todo stack in reverse order to be order-compatible with the old DFS implementation)
                    // for
                    var i = nodeEdges.length - 1;
                    while(i >= 0) {
                        todo.push({ node: nodeEdges[i], processed: false });
                        i--;
                    } 
                    current.processed = true;
                } 
                else {
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

}

#end