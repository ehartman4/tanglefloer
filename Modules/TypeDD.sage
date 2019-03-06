import numpy as np

class TypeDD:
	# gens - a list of generators
    # edges_out - a dictionary keyed by source generators
    # edges_in - a dictionary keyed by target generators
    # deleted edge data...it is stored in the gens
    # dictionary values are lists of edges (each edge is a 5-tuple (source, target, a, b, m))
	def __init__(self,gens,edges_out):
		self.gens = gens # this should just be a list of tuples [eL,eR]
		self.edges_out = edges_out
		self.edges_in = self.dictTargEdges(edges_out) # Emma says: does anyone need this besides reducation people? I don't think it should be in __init__
	
	# other is a TypeAA (only option for TypeDD)
	def tensor(self, other):
		#assert self.rightalgebra = other.leftalgebra, #pseudo - where are the left and right algebras stored?
		#	"Error: Algebras not compatible"
		MNgens = np.zeros(length(self.gens),length(other.gens)) # I think a list will be more efficient than a matrix, since it will probably be quite sparse, but we should discuss
		listKey = 0
		for i in length(self.gens):
			for j in length(other.gens):
				if self.gens[i][1] == other.gens[j][0]: #this assumes generators are a tuple (eL, eR)
					MNgens[i][j] = [self.gens[i][0],other.gens[j][1],listKey] #(xeL, yeR)
					listKey += 1
		MNedgeDict = {}

		for j in length(other.gens):
			for yedge in other.edges_out[j]:
				for i in length(self.gens):
					if MNgens[i][j] != 0:
						if yedge.a_coefficient == []:
							self.add_to_dict(MNgens[i][j][2],MNedgeDict,Edge(MNgens[i][j][2], MNgens[i][yedge.target][2], [], yedge.b_coefficient, yedge.m_coefficient))
						else: #if a_coeff is not empty
							for xedge in self.edges_out[i]:
								if xedge.b_coefficient == yedge.a_coefficient:
									self.add_to_dict(MNgens[i][j][2],MNedgeDict,Edge(MNgens[i][j][2],MNgens[i][yedge.target][2], xedge.a_coefficient,yedge.b_coefficient, xedge.m_coefficient*yedge.m_coefficient))
							####### Trying to add the option for y to have multiple algebra elements:
							recurse_source = i #start recursion with x_i
							#for xedge in self.edges_out[recurse_source]:
							#	counter = 0
							self.match_path(i,yedge.a_coefficient)


							###### end new section

		for i in length(self.gens):
			for xedge in self.edges_out[i]:
				for j in length(other.gens):
					if MNgens[i][j] != 0:
						if xedge.b_coefficient == []:
							self.add_to_dict(MNgens[i][j][2],MNedgeDict,Edge(MNgens[i][j][2], MNgens[xedge.target][j][2],xedge.a_coefficient, [], xedge.m_coefficient))

		#put generators in list
		outGenList = []
		for i in length(self.gens):
			for j in length(other.gens):
				if MNgens[i][j] != 0:
					outGenList.append([MNgens[i][j][0],MNgens[i][j][1]])

		return TypeDA(outGenList,MNedgeDict)

	def match_path(self,recurse_source,y_a_coeff)
	#TODO: track u variables as well (m_coefficient) and multiple l_coeff from DD edges as you go
	#TODO: order of y coeff. vs. x path? backwards or forwards?
		if y_a_coeff = []: 
			return recurse_source
		for xedge in self.edges_out[recurse_source]:
			if xedge.b_coefficient == y_a_coeff[0]:#DD edges stored as lists or one element??
				y_a_coeff.pop(0)
				match_path(xedge.target,y_a_coeff)
		return 0 ## need a way to get out if there is no path. I think this will do that...

	def add_to_dict(self,index_key,in_dict,new_edge):
		if index_key in in_dict:
			in_dict[index_key].append(new_edge)
		else:
			in_dict[index_key] = [new_edge] #need to return dictionary??


	#creates a dictionary of the edges, keyed by target vertex. The values are a list of edges.
	def dictTargEdges(self,inEdgeDict):
		outEdgeDict = {}
		for s in inEdgeDict:
			for e in inEdgeDict[s]:
				if e.target in outEdgeDict:
					outEdgeDict[e.target].append(e)
				else:
					edgeDict[e.target] = [e]
		return edgeDict

		
    # test if edge is empty
    # maybe this should go somewhere else ?
    # input is an edge
    def is_empty_edge(self):
        assertion_1 = (self.source.idempotent_left == self.a_coefficient)
        assertion_2 = (self.source.idempotent_right == self.a_coefficient)
        assertion_3 = (self.m_coefficient == 1) # 1 in kk
        if assertion_1 and assertion_2 and assertion_3:
            return True
        else:
            return False

    # input is list of generators
	def get_reducible_edge(self):
        for x in self.gens:
            for e in x.edges_out:
                if is_empty_edge(e):
                    # now check to see if there are other edges between x and target of e
                    y = e[1] # target of e
                    # check size of list of edges from x to y is 1
                    assertion_1 = len(get_edges_between(self, x, y)) == 1
                    # check that there are no edges from y to x
                    assertion_2 = len(get_edges_between(self, y, x)) == 0
                    if assertion_1 and assertion_2:
                        return [e]
        return []

    # get edges z->w
    # M: TypeDD
    # z: source generator
    # w: target generator
    # returns list of edges z->w
    def get_edges_between(M, z, w):
        edges_out_z = M.edges_out(z)
        edges_in_w = M.edges_in(w)
        edges = []
        for edge in edges_out_z:
            if edge in edges_in_w:
                edges.append(edge)
        return edges

    # input is a TypeDD
    # copy generators and update
    # or we could build a new TypeDD completely...
    def reduce(self):
        # first look for a reducible edge
        edge_list = get_reducible_edges(self.gens)
        if len(edge_list) == 0: # in this case self is reduced
            return self
        else: # in this case we have at least one edge to reduce
            edge = edge_list[0]
            x = edge.source
            y = edge.target
            # new list of generators without reference to self.gens
            new_gens = []
            for v in self.gens:
                if v != x and v != y:
                    new_gens.append(v)
            # new edges_out edges_in dictionaries each with an empty list of edges
            new_edges_out = {}
            new_edges_in = {}
            for v in new_gens:
                new_edges_out[v] = []
                new_edges_in[v] = []
            for z in new_gens:
                # compute all targets of z
                z_targets = [ edge[1] for edge in z.edges_out ]
                for w in new_gens:
                    # get edge(s) z->w
                    edges_z_to_w = get_edges_between(self, z, w)
                    z_points_to_y = y in z_targets
                    # compute all sources of w
                    w_sources = [ edge[0] for edge in w.edges_in ]
                    x_points_to_w = x in w_sources
                    # if z points to y and x points to x then update edge from z to w
                    if z_points_to_y and x_points_to_w: # otherwise don't update anything
                        # TODO: a, b, m determined by MATH
                        new_edge = Edge(z, w, a, b, m)
                        new_edges_out[z].append(new_edge)
                        new_edges_in[w].append(new_edge)
                    else: # just copy over from previous dictionaries
                        new_edges_out[z] += edges_z_to_w
                        new_edges_in[w] += edges_z_to_w
            # delete all x,y data
            # delete source and target generators of edge to be reduced
            new_gens.remove(source)
            new_gens.remove(target)
            # make new TypeDD
            break

    # Emma asks: is this getting used by anyone??
    class Generator:
        # in/out edges
        # left/right idempotents
        def __init__(self, edges_in, edges_out, idempotent_left, idempotent_right):
            self.edges_in = edges_in
            self.edges_out = edges_out
            self.idempotent_left = idempotent_left
            self.idempotent_right = idempotent_right

	# represents the action of some delta_1 on some pair of generators
	class Edge:
		# source, target - elements of gens
		# a_coefficient - element of A
		# m_cofficient - element of k
		# b_coefficient - element of B
		# 
		# condition: delta_1(source) = a_coefficient (X) (m_coefficient * target) (X) b_coefficient
        def __init__(self, source, target, a_coefficient, b_coefficient, m_coefficient):
			self.source = source
			self.target = target
			self.a_coefficient = a_coefficient
			self.b_coefficient = b_coefficient
			self.m_coefficient = m_coefficient
