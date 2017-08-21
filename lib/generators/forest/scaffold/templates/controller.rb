<% module_namespacing do -%>
class <%= class_name %>sController < ForestController
  before_action :set_<%= singular_name %>, only: [:show]

  def index
    # TODO: active/statusable scope
    @<%= plural_name %> = apply_scopes(<%= name %>)
  end

  def show
    authorize @<%= singular_name %>
  end

  private
    def set_<%= singular_name %>
      @<%= singular_name %> = <%= name %>.find_by_slug(params[:id])
    end
end
<% end -%>
