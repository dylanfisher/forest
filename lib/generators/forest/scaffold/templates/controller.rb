<% module_namespacing do -%>
class <%= plural_name.camelize %>Controller < ForestController
  before_action :set_<%= singular_name %>, only: [:show]

  def index
    # TODO: published/statusable scope
    @<%= plural_name %> = apply_scopes(<%= name %>)
  end

  def show
    authorize @<%= singular_name %>
  end

  private

    def set_<%= singular_name %>
      @<%= singular_name %> = <%= name %>.find_by!(slug: params[:id])
    end
end
<% end -%>
