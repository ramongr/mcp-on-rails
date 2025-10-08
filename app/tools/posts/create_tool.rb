module Posts
  class CreateTool < MCP::Tool
    tool_name "post-create-tool"
    description "Create a new Post entity"

    input_schema(
      properties: {
        title: { type: "string" },
        content: { type: "string" },
        author: { type: "string" },
      },
      required: [  ]
    )

    def self.call(title: nil, content: nil, author: nil, server_context:)
      post = Post.new(
        title: title,
content: content,
author: author
      )

      if post.save
        MCP::Tool::Response.new([ { type: "text", text: "Created #{post.to_mcp_response}" } ])
      else
        MCP::Tool::Response.new([ { type: "text", text: "Post was not created due to the following errors: #{post.errors.full_messages.join(', ')}" } ])
      end
    rescue StandardError => e
      MCP::Tool::Response.new([ { type: "text", text: "An error occurred, what happened was #{e.message}" } ])
    end
  end
end
