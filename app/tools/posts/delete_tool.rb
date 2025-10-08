module Posts
  class DeleteTool < MCP::Tool
    tool_name "post-delete-tool"
    description "Delete a Post entity of the given ID"

    input_schema(
      properties: {
        id: { type: "integer" }
      },
      required: [ "id" ]
    )

    def self.call(id:, server_context:)
      post = Post.find(id)
      post.destroy!

      MCP::Tool::Response.new([ { type: "text", text: "Post of id = #{id} was deleted" } ])
    rescue ActiveRecord::RecordNotFound
      MCP::Tool::Response.new([ { type: "text", text: "Post of id = #{id} was not found" } ])
    rescue StandardError => e
      MCP::Tool::Response.new([ { type: "text", text: "An error occurred, what happened was #{e.message}" } ])
    end
  end
end
