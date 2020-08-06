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

typedef Options = {
    circular: Bool
}

//   export class DepGraphCycleError extends Error {
//     cyclePath: String[];
//   }

class DepGraph<T>
{
    public function new(opts: Options) : Void
    {

    }



    /**
     * Creates an instance of DepGraph with optional Options.
     */
    // constructor(opts?: Options);

    /**
     * The number of nodes in the graph.
     */
    public function size(): Int
    {
        return 0;
    }

    /**
     * Add a node in the graph with optional data. If data is not given, name will be used as data.
     * @param {string} name
     * @param data
     */
    public function addNode(name: String, data: T): Void
    {

    }

    /**
     * Remove a node from the graph.
     * @param {string} name
     */
    public function removeNode(name: String): Void
    {

    }

    /**
     * Check if a node exists in the graph.
     * @param {string} name
     */
    public function hasNode(name: String): Bool
    {
        return false;
    }

    /**
     * Get the data associated with a node (will throw an Error if the node does not exist).
     * @param {string} name
     */
    public function getNodeData(name: String): T
    {
        return null;
    }

    /**
     * Set the data for an existing node (will throw an Error if the node does not exist).
     * @param {string} name
     * @param data
     */
    public function setNodeData(name: String, data: T): Void
    {

    }

    /**
     * Add a dependency between two nodes (will throw an Error if one of the nodes does not exist).
     * @param {string} from
     * @param {string} to
     */
    public function addDependency(from: String, to: String): Void
    {

    }

    /**
     * Remove a dependency between two nodes.
     * @param {string} from
     * @param {string} to
     */
    public function removeDependency(from: String, to: String): Void
    {

    }

    /**
     * Return a clone of the dependency graph (If any custom data is attached
     * to the nodes, it will only be shallow copied).
     */
    public function clone(): DepGraph<T>
    {
        return null;
    }

    /**
     * Get an array containing the nodes that the specified node depends on (transitively). If leavesOnly is true, only nodes that do not depend on any other nodes will be returned in the array.
     * @param {string} name
     * @param {boolean} leavesOnly
     */
    public function dependenciesOf(name: String, leavesOnly: Bool): Array<String>
    {
        return [];
    }

    /**
     * Get an array containing the nodes that depend on the specified node (transitively). If leavesOnly is true, only nodes that do not have any dependants will be returned in the array.
     * @param {string} name
     * @param {boolean} leavesOnly
     */
    public function dependantsOf(name: String, leavesOnly: Bool): Array<String>
    {
        return [];
    }

    /**
     * Construct the overall processing order for the dependency graph. If leavesOnly is true, only nodes that do not depend on any other nodes will be returned.
     * @param {boolean} leavesOnly
     */
    public function overallOrder(leavesOnly: Bool): Array<String>
    {
        return [];
    }

}

#end