module Sortable
  def organisations_sort_column
    params[:type] == "draft" ? (sort_column || "created_at") : sort_column
  end

  def organisations_sort_order
    params[:type] == "draft" ? (sort_order || "desc") : sort_order
  end

  def sort_column
    params[:sort_column]
  end

  def sort_order
    params[:sort_order]
  end
end
