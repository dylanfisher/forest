<% module_namespacing do -%>
class <%= plural_name.camelize %>Controller < ForestController
  before_action :set_<%= singular_name %>, only: [:show]

  def index
    # TODO: published/statusable scope
    skip_authorization
    @<%= plural_name %> = apply_scopes(<%= name %>)
  end

  def show
    authorize @<%= singular_name %>
  end

  private

  def set_<%= singular_name %>
    <%- if options.skip_sluggable? -%>
    @<%= singular_name %> = <%= name %>.find(params[:id])
    <%- else -%>
    @<%= singular_name %> = <%= name %>.find_by!(slug: params[:id])
    <%- end -%>
  end
end
<% end -%>
