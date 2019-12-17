
class ParentObj {
    public:
        ParentObj(){};
        ~ParentObj(){};
}

class Node {
    private:
        ParentObj * obj;
        Node * next;
    public:
        Node(ParentObj* &object) {
            obj = object;
            next = null;
        }
        ~Node() {
            delete(obj);
            next = null;
        }
        Node * GetNext() {
            return next;
        }
        ParentObj * GetVal() {
            return obj;
        }
        void AddNext(Node* &node) {
            next = node;
        }
}

class List {
    private:
        Node * rootNode;
        Node * currNode; //Usually last node, unless list is looping
    public:
        List() {
            rootNode = null;
            currNode = null;
        }
        ~List() {
            DeleteAll();
        }
        void Add(ParentObj* &object) {
            if(rootNode == null) {
                rootNode = new Node(object);
                currNode = rootNode;
            } else {
                Node * n = new Node(object);
                currNode.AddNext(n);
                currNode = n;
            }
        }
        void Start() {
            currNode = rootNode;
        }
        bool Loop() {
            return currNode.GetNext() != null;
        }
        ParentObj * Get() {
            ParentObj * obj = currNode.GetVal();
            if(currNode.GetNext() != null)
                currNode = currNode.GetNext();
            return obj;
        }
        Node * GetNode() {
            Node * node = currNode;
            if(currNode.GetNext() != null)
                currNode = currNode.GetNext();
            return node;
        }
        ParentObj * Get() {
            ParentObj * obj = currNode.GetVal();
            if(currNode.GetNext() != null)
                currNode = currNode.GetNext();
            return obj;
        }
        void DeleteAll() {
            Start();
            while(Loop()) {
                delete(GetNode());
            }
        }
}