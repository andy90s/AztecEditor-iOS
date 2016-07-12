import Foundation
import libxml2

extension Libxml2.Out {
    class NodeConverter: Converter {

        typealias Attribute = HTML.Attribute
        typealias ElementNode = HTML.ElementNode
        typealias Node = HTML.Node
        typealias TextNode = HTML.TextNode

        /// Converts a single node (from libxml2) into an HTML.Node.
        ///
        /// - Parameters:
        ///     - attributes: the libxml2 attribute to convert.
        ///
        /// - Returns: an HTML.Node.
        ///
        func convert(rawNode: xmlNode) -> Node {
            var node: Node!

            let nodeName = getNodeName(rawNode)

            if nodeName.lowercaseString == "text" {
                node = createTextNode(rawNode)
            } else {
                node = createElementNode(rawNode)
            }

            return node
        }

        private func createAttributes(fromNode rawNode: xmlNode) -> [Attribute] {
            let attributesConverter = AttributesConverter()
            return attributesConverter.convert(rawNode.properties)
        }

        /// Creates an HTML.Node from a libxml2 element node.
        ///
        /// - Parameters:
        ///     - rawNode: the libxml2 xmlNode.
        ///
        /// - Returns: the HTML.ElementNode
        ///
        private func createElementNode(rawNode: xmlNode) -> Node {
            let nodeName = getNodeName(rawNode)
            var children = [Node]()

            if rawNode.children != nil {
                let nodesConverter = NodesConverter()
                children.appendContentsOf(nodesConverter.convert(rawNode.children))
            }

            let attributes = createAttributes(fromNode: rawNode)
            let node = ElementNode(name: nodeName, attributes: attributes, children: children)

            return node
        }

        /// Creates an HTML.TextNode from a libxml2 element node.
        ///
        /// - Parameters:
        ///     - rawNode: the libxml2 xmlNode.
        ///
        /// - Returns: the HTML.TextNode
        ///
        private func createTextNode(rawNode: xmlNode) -> TextNode {
            let nodeName = getNodeName(rawNode)

            let text = String(CString: UnsafePointer<Int8>(rawNode.content), encoding: NSUTF8StringEncoding)!
            let attributes = createAttributes(fromNode: rawNode)
            let node = TextNode(name: nodeName, text: text, attributes: attributes)

            return node
        }

        private func getNodeName(rawNode: xmlNode) -> String {
            return String(CString: UnsafePointer<Int8>(rawNode.name), encoding: NSUTF8StringEncoding)!
        }
    }
}