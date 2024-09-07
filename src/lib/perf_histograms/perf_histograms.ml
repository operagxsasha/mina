open Core_kernel

module type CONTEXT = sig
  val block_window_duration : Time.Span.t
end

module F (Context : CONTEXT) = struct
  module Report = Histogram.Exp_time_spans.Pretty
  module Rpc = Rpc.F (Context)
  include Perf_histograms0
end
