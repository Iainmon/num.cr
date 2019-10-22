require "../libs/dtype"
require "../libs/cblas"
require "../core/flask"
require "../core/jug"

module Bottle
  macro blas_helper(dtype, blas_prefix, cast)
    module Bottle::BLAS
      extend self

      # Performs matrix multiplication of two Jugs.
      #
      # `C := alpha*op( A )*op( B ) + beta*C`
      # where  `op( X )`` is one of
      # `op( X ) = X`   or   `op( X ) = X**T`
      # `alpha` and `beta` are scalars, and `A`, `B` and `C` are Jugs, with `op( A )`
      # an `m` by `k` Jug,  `op( B )`  a `k` by `n` Jug and `C` an `m` by `n` Jug.
      #
      # ```
      # j = Jug.new [[1.0, 2.0], [3.0, 4.0]]
      # matmul(j, j) # =>
      #
      # [[2.0, 3.0],
      # [6.0, 11.0]]
      # ```
      def matmul(a : Jug({{dtype}}), b : Jug({{dtype}}))
        c = Jug({{dtype}}).empty(a.nrows, b.ncols)
        LibCblas.{{blas_prefix}}gemm(
          LibCblas::MatrixLayout::RowMajor,
          LibCblas::MatrixTranspose::NoTrans,
          LibCblas::MatrixTranspose::NoTrans,
          a.nrows,
          b.ncols,
          a.ncols,
          1{{cast}},
          a.data,
          a.tda,
          b.data,
          b.tda,
          0{{cast}},
          c.data,
          c.tda,
        )
        return c
      end
    end
  end

  blas_helper Float64, d, _f64
  blas_helper Float32, s, _f32
end