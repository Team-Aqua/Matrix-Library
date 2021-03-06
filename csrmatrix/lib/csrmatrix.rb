require "csrmatrix/version"
require "csrmatrix/arithmetic"
require "csrmatrix/properties"
require "csrmatrix/functions"
require "csrmatrix/decompositions"
require "csrmatrix/operations"
require "csrmatrix/helpers"
require "csrmatrix/exceptions"
require "contracts"
require "csrmatrix/mcontracts"

module CsrMatrix
  # The current website ref. Used for verificationn of rb systems.
  Url = "https://github.com/Team-Aqua/Matrix-Library/"  

end# CsrMatrix


# General code convention in this manner - generate documentation via 'rdoc lib'.
class TwoDMatrix
  #Need to ensure we include Object Class overwrites.
  include CsrMatrix::Operations
  include CsrMatrix::Properties
  include CsrMatrix::Arithmetic
  include CsrMatrix::Functions
  include CsrMatrix::Decompositions
  include CsrMatrix::Helpers
  include CsrMatrix::Exceptions
  include CsrMatrix::MContracts
  include Contracts::Core
  include Contracts::Invariants

  C = Contracts
  #These only get called post Methods with Contract Decorator
  invariant(@rows) { @rows >= 0}
  invariant(@columns) { @columns >= 0}
  invariant(:val) {self.val != nil}

  def is_invariant?
    if @val == nil
      raise InvariantError.new, "Empty Matrix"
      return false
    end
    if @columns < 0
      raise InvariantError.new, "Invalid Column Dimension"
      return false
    end
    if @rows < 0
      raise InvariantError.new, "Invalid Row Dimension"
      return false
    end
    return true
  end

  # The current website ref. Used for verification of rb systems.
  Url = "https://github.com/Team-Aqua/Matrix-Library/"
  attr_reader :row_ptr, :col_ind, :val, :rows, :columns, :ndim

  # Blank setup; setup module.
  def initialize()	
    @nonzero_count = nil
    @row_ptr = nil
    @col_ind = nil
    @val = nil
    @rows = 0
    @columns = 0
    @ndim = 2
  end # initialize

  ##
  # SPARSE MATRIX ATTRIBUTE OPERATORS 
  # matrix attributes and overloaded operators
  #

  # equals override for matrix operations
  def ==(o)
    # equals overide to check if object o equals self
    # pre   o, self
    # post  true if o is_a csrmatrix and o == self
    o.class == self.class && o.state == state
  end # ==(o)

  # Contract C::None => C::ArrayOf[ArrayOf[C::Num],ArrayOf[C::Nat],ArrayOf[C::Nat],C::Nat,C::Nat,C::Nat]
  def state
    # returns the current state of the csrmatrix
    # pre self
    # post [@value, @row_pointer, @column_index, @rows, @columns, @dimension]
    [@val, @row_ptr, @col_ind, @rows, @columns, @ndim]
  end # state

  # Finds column and row value of an array. 
  Contract C::None => C::ArrayOf[C::Nat]
  def dimensions()
    is_invariant?
    # returns the dimensions of the csrmatrix
    return [@rows, @columns]
  end # dimensions

  Contract C::Nat, C::Nat => C::Bool 
  def checkInputBounds(row, col)
    # checks whether or not the index searched is within bounds	
    if row > @rows
      raise IndexOutOfRangeException.new, "Row index too large"
      return false
    elsif col > @columns
      raise IndexOutOfRangeException.new, "Column index too large"
      return false
    elsif row < 0
      raise IndexOutOfRangeException.new, "Row index too small"
      return false
    elsif col < 0
      raise IndexOutOfRangeException.new, "Column index too small"
      return false
    else
      return true
    end
  end # checkInputBounds

  ##
  # MATRIX DECOMPOSITION FUNCTIONS
  #

  Contract C::None => C::ArrayOf[C::ArrayOf[CsrMatrix::MContracts::ValidMatrixNum]]
  def decompose()
		# decompose the matrix into an array
		is_invariant?
		# post array from the csrmartix
    res = Array.new(@rows) { Array.new(@columns, 0) }
    row_counter = 0
    row_idx = 0
    @row_ptr.drop(1).each do |i| #eg. 2 4 7 10
      while row_counter < i 
        res[row_idx][@col_ind[row_counter]] = @val[row_counter]
        row_counter += 1
      end 
      row_idx += 1
    end
    return res
  end # decompose

  Contract C::None => Matrix
  def decomp_to_matrix()
    @matrix = Matrix.rows(self.decompose())
    return @matrix
  end # decomp_to_matrix

  ##
  # MATRIX GENERATION FUNCTIONS 
  # generation of csr matrix
  #

  # Builds when given a 2d array to CSR
  Contract C::ArrayOf[C::ArrayOf[CsrMatrix::MContracts::ValidInputNum]] => C::ArrayOf[CsrMatrix::MContracts::ValidMatrixNum] 
  def build_from_array(array)
		#Contracts: Pre
    if !same_sublength(array)
      raise MatrixDimException.new, "Invalid row/column pairs imported."
      return false
    end
    #END Contracts: Pre
    @val = [] #Allows Invariant Check to Pass for following method call
    @columns, @rows, nonzero_count, @val, @row_ptr, @col_ind = convert_to_csr(array)
    @val
  end # build_from_array

    # Finds the column count, row count and non-zero values in one loop.
  Contract C::ArrayOf[C::ArrayOf[C::Num]] => C::Any 
  def convert_to_csr(array)
    # converts a given array to csr format
    # pre  array


    # post csrmatrix from array
    row_count = 0
    col_count = 0
    nonzero_count = 0

    row_val = 0
    row_prev_sum = 0

    col_val = 0

    value_array = Array.new
    row_ptr = Array.new
    col_ind = Array.new
    
    array.each_index do |i| # each row
      col_val = 0 # eg. for pos [0, 1, 2, 3] it goes 0, 1, 2, 3
      col_tmp = 0
      row_count += 1
      row_prev_sum = row_val
      row_ptr << row_prev_sum # ref: http://op2.github.io/PyOP2/linear_algebra.html
      subarray = array[i]
      subarray.each_index do |x| # each column entry in row
        col_tmp += 1
        if array[i][x] != 0
          # use nonzero value in CSR
          if array[i][x] == nil
            return false
          end
          nonzero_count += 1
          value_array << array[i][x]
          col_ind << col_val
          row_val += 1
        end
        col_val += 1 # eg. col_val add at the end
      end
      if col_tmp >= col_count
        col_count = col_tmp
      end
    end
    row_prev_sum = row_val
    row_ptr << row_prev_sum
    return [col_count, row_count, nonzero_count, value_array, row_ptr, col_ind]
  end # convert_to_csr

  # builds matrix dependent on input
  Contract String, C::Or[C::ArrayOf[C::Or[C::ArrayOf[C::Num], C::Num]],C::Nat, Matrix], C::Or[nil, Any, C::None] => C::Bool
  def build(type, data, extra = nil)
    # builds matrix dependent on input
    # pre   string type
    #       data, dependent type
    # post  generated matrix
    #       boolean depending on build
    case type 
      when "matrix"
        self.build_from_matrix(data)
      when "row", "rows"
        self.build_from_rows(data)
      when "array"
        self.build_from_array(data)
      when "column", "columns"
        self.build_from_columns(data)
      when "identity", "i", "unit"
        self.build_identity_matrix(data)
      when "zero"
        if extra != nil 
          self.build_zero_matrix(data, extra)
        else
          self.build_zero_matrix(data)
        end
      when "csr"
        self.build_from_csr(data[0], data[1], data[2], data[3], data[4])
      else 
        raise MatrixTypeException.new, "Bad build type, no build response."
        return false;
      end 
      return true;
  end   

  # imports a matrix from a matrix library
  Contract Matrix => C::Bool
  def build_from_matrix(matrix)
		# builds a csr matrix a ruby matrix
    build_from_array(matrix.to_a())
    return true
  end # build_from_matrix

  # builds a matrix given its rows
  Contract C::ArrayOf[C::ArrayOf[CsrMatrix::MContracts::ValidInputNum]] => C::ArrayOf[CsrMatrix::MContracts::ValidMatrixNum]
  def build_from_rows(array)
		# builds a csr matrix from rows
    build_from_array(array)
    self.transpose()
    @val
  end # build_from_rows


  
  Contract C::ArrayOf[C::ArrayOf[CsrMatrix::MContracts::ValidInputNum]] => C::ArrayOf[CsrMatrix::MContracts::ValidMatrixNum]
  def build_from_columns(array)
    # builds a matrix given its columns ;; redirect to array build
		# build a matrix given columns. same implimentation as array build
    self.build_from_array(array)
    @val
  end # build_from_columns

  # generates an identity matrix
  Contract C::Nat => true
  def build_identity_matrix(size)
		# generate identity matrix of a given size
    if size > 100
      raise CsrMatrix::Exceptions::InputOverflowError.new "Identity Matrix cannot be instantiated larger than 100"
      return false
    end

    @columns = size
    @rows = size
    @col_ind = 0.step(size-1, 1).to_a
    @row_ptr = 0.step(size,1).to_a
    @nonzero_count = size
    @val = Array.new(size, 1)
    return true
  end # build_identity_matrix

  # generates a zero matrix
  Contract C::Nat, C::Nat => true
  def build_zero_matrix(rows, columns = rows)
		# generate a matrix with all values equaling zero for a given number of rows and columns
    if rows > 100 or columns > 100
      raise CsrMatrix::Exceptions::InputOverflowError.new "Zero Matrix cannot be instantiated larger than 100"
      return false
    end

    @row_ptr = Array.new(rows + 1, 0)
    @col_ind = Array.new(0)
    @val = Array.new(0)
    @rows = rows
    @columns = columns
    @nonzero_count = nil
    return true
  end # build_zero_matrix

  # Builds array using user-generated CSR values
  Contract C::ArrayOf[C::Nat], C::ArrayOf[C::Nat], C::ArrayOf[CsrMatrix::MContracts::ValidInputNum], C::Nat, C::Nat => TwoDMatrix
  def build_from_csr(row_ptr, col_ind, val, col_siz, row_siz)
    # generate an array from user generated csr values
    @val = val
    @row_ptr = row_ptr
    @col_ind = col_ind
    @rows = row_siz
    @columns = col_siz
    self
  end # build_from_csr

  # ensures that all subarrays are of same length
  #FIXME: Could be a contract in itself
  def same_sublength(array)
		# ensures that all sub arrays have the same length
    testLength = array[0].length
    array.each do |subarray|
      if(subarray.length != testLength)
				return false
      end
    end
    return true
  end #same_sublength

end # TwoDMatrix
